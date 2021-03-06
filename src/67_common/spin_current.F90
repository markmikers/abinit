!{\src2tex{textfont=tt}}
!!****f* ABINIT/spin_current
!! NAME
!! spin_current
!!
!! FUNCTION
!!
!! COPYRIGHT
!! Copyright (C) 2005-2012 ABINIT group (Mver)
!! This file is distributed under the terms of the
!! GNU General Public License, see ~abinit/COPYING
!! or http://www.gnu.org/copyleft/gpl.txt .
!!
!! INPUTS
!!  atindx(natom)=index table for atoms (see scfcv.f)
!!  atindx1(natom)=inverse of atindx
!!  cg(2,mcg)=wavefunctions (may be read from disk instead of input)
!!  dtfil <type(datafiles_type)>=variables related to files
!!  dtset <type(dataset_type)>=all input variables in this dataset
!!  eigen(mband*nkpt*nsppol)=array for holding eigenvalues (hartree)
!!  gmet = reciprocal space metric
!!  gprimd = dimensionful reciprocal space vectors
!!  hdr <type(hdr_type)>=the header of wf, den and pot files
!!  kg(3,mpw*mkmem)=reduced (integer) coordinates of G vecs in basis sphere
!!  mcg=size of wave-functions array (cg) =mpw*nspinor*mband*mkmem*nsppol
!!  mpi_enreg=informations about MPI parallelization
!!  nattyp(dtset%ntypat)=number of atoms of each type
!!  nfftf = fft grid dimensions for fine grid
!!  ph1d = phase factors in 1 radial dimension
!!  psps <type(pseudopotential_type)>=variables related to pseudopotentials
!!   | mpsang= 1+maximum angular momentum
!!  rhog(2,nfftf)=Fourier transform of total electron density (including compensation density in PAW)
!!  rhor(nfftf,nspden)=total electron density (including compensation density in PAW)
!!  rmet = real space metric tensor
!!  symrec(3,3,nsym)=symmetries in reciprocal space, reduced coordinates
!!  ucvol = unit cell volume
!!  wffnow=unit number for current wf disk file
!!  ylm(mpw*mkmem,mpsang*mpsang*useylm)= real spherical harmonics for each G and k point
!!  ylmgr(mpw*mkmem,3,mpsang*mpsang*useylm)= gradients of real spherical harmonics
!!
!! OUTPUT
!!   only output to file
!!
!! SIDE EFFECTS
!!
!! NOTES
!!
!! PARENTS
!!      afterscfloop
!!
!! CHILDREN
!!      fourwf,leave_new,printxsf,sphereboundary,vso_realspace_local,wrtout
!!      xredxcart
!!
!! SOURCE

#if defined HAVE_CONFIG_H
#include "config.h"
#endif

#include "abi_common.h"

subroutine spin_current(cg,dtfil,dtset,gprimd,hdr,kg,mcg,mpi_enreg,psps)

 use m_profiling

 use defs_basis
 use defs_datatypes
 use defs_abitypes
 use m_wffile

!This section has been created automatically by the script Abilint (TD).
!Do not modify the following lines by hand.
#undef ABI_FUNC
#define ABI_FUNC 'spin_current'
 use interfaces_14_hidewrite
 use interfaces_16_hideleave
 use interfaces_32_util
 use interfaces_42_geometry
 use interfaces_53_ffts
 use interfaces_67_common, except_this_one => spin_current
!End of the abilint section

 implicit none

!Arguments ------------------------------------
!scalars
!integer,intent(in) :: nfftf
!real(dp),intent(in) :: ucvol
 integer,intent(in) :: mcg
 type(MPI_type),intent(inout) :: mpi_enreg
 type(datafiles_type),intent(in) :: dtfil
 type(dataset_type),intent(in) :: dtset
 type(hdr_type),intent(inout) :: hdr
 type(pseudopotential_type),intent(in) :: psps
!type(wffile_type),intent(in) :: wffnow
!arrays
!integer,intent(in) :: atindx(dtset%natom),atindx1(dtset%natom)
 integer,intent(in) :: kg(3,dtset%mpw*dtset%mkmem)
!integer,intent(in) :: nattyp(dtset%ntypat)
!integer,intent(in) :: symrec(3,3,dtset%nsym)
 real(dp),intent(in) :: cg(2,mcg)
!real(dp),intent(in) :: eigen(dtset%mband*dtset%nkpt*dtset%nsppol),gmet(3,3)
 real(dp),intent(in) :: gprimd(3,3)
!real(dp),intent(in) :: rhog(2,nfftf),rhor(nfftf,dtset%nspden)
!real(dp),intent(in) :: rmet(3,3)
!real(dp),intent(in) :: ylm(dtset%mpw*dtset%mkmem,psps%mpsang*psps%mpsang*psps%useylm)
!real(dp),intent(in) :: ylmgr(dtset%mpw*dtset%mkmem,3,psps%mpsang*psps%mpsang*psps%useylm)
!real(dp),intent(inout) :: ph1d(2,3*(2*dtset%mgfft+1)*dtset%natom)

!Local variables-------------------------------
!scalars
 integer :: cplex,fft_option,i1
 integer :: i2,i3,iband,icartdir,icg,ig
 integer :: ikg,ikpt,iocc,iost,irealsp,ispindir,ispinor,ispinorp
 integer :: npw,spcur_unit
 integer :: icplex
 integer :: realrecip
 integer :: iatom
 real(dp) :: prefact_nk
 real(dp) :: rescale_current
 character(len=500) :: message
 character(len=fnlen) :: filnam
!arrays
 integer,allocatable :: gbound(:,:),kg_k(:,:)
 real(dp),allocatable :: dpsidr(:,:,:,:,:,:)
 real(dp),allocatable :: density(:,:,:,:)
 real(dp),allocatable :: dummy_denpot(:,:,:)
 real(dp),allocatable :: gpsi(:,:,:,:),kgcart(:,:)
 real(dp),allocatable :: position_op(:,:,:,:)
 real(dp),allocatable :: psi(:,:,:),psi_r(:,:,:,:,:)
 real(dp),allocatable :: spincurrent(:,:,:,:,:)
 real(dp),allocatable :: vso_realspace(:,:,:,:,:)
 real(dp),allocatable :: dummy_fofgout(:,:)
 real(dp),allocatable :: xcart(:,:)
 character :: spin_symbol(3)
 character :: spinor_sym(2)
 character*2 :: realimag(2)
!no_abirules
!real(dp),allocatable :: density_matrix(:,:,:,:,:)
!real(dp),allocatable :: vso_realspace_nl(:,:,:,:,:)

! *************************************************************************
!source

 write(std_out,*) ' Entering subroutine spin_current '
 write(std_out,*) ' dtset%ngfft = ', dtset%ngfft
 write(std_out,*) ' hdr%istwfk = ', hdr%istwfk

!===================== init and checks ============================  
!check if nspinor is 2
 if (dtset%nspinor /= 2) then
   write(message, '(a,a,a,a,i6,a,i6,a,a)' ) ch10,&
&   ' spin_current : ERROR -',ch10,&
&   '  nspinor must be 2, but it is ',dtset%nspinor,ch10
   call wrtout(std_out,message,'PERS')
   call leave_new('PERS')
 end if

 if (dtset%nsppol /= 1) then
   write(message, '(a,a,a,a,i6,a)' ) ch10,&
&   ' spin_current : ERROR -',ch10,&
&   ' nsppol must be 1 but it is ',dtset%nsppol,ch10
   call wrtout(std_out,message,'PERS')
   call leave_new('PERS')
 end if

 if (dtset%mkmem /= dtset%nkpt) then
   write(message, '(a,a,a,a,i6,a,i6,a,a)' ) ch10,&
&   ' spin_current : ERROR -',ch10,&
&   ' mkmem =  ',dtset%mkmem,' must be equal to nkpt ',dtset%nkpt,&
&   ch10,' keep all kpt in memory'
   call wrtout(std_out,message,'PERS')
   call leave_new('PERS')
 end if

 if (dtset%usepaw /= 0) then
   write(message, '(a,a,a,a,i6,a,a,a)' ) ch10,&
&   ' spin_current : ERROR -',ch10,&
&   ' usepaw =  ',dtset%usepaw,' must be equal to 0 ',&
&   ch10,' Not functional for PAW case yet.'
   call wrtout(std_out,message,'PERS')
   call leave_new('PERS')
 end if

 cplex=2
 fft_option = 0 ! just do direct fft
 spin_symbol = (/'x','y','z'/)
 spinor_sym = (/'u','d'/)
 realimag = (/'Re','Im'/)

 
 write(std_out,*) ' psps%mpsang,psps%mpssoang ', psps%mpsang,psps%mpssoang

!======================= main code ================================  
!-----------------------------------------------------------------------------------------
!-----------------------------------------------------------------------------------------
!first get normal contribution to current, as psi tau dpsidr + dpsidr tau psi
!where tau are 1/2 the pauli matrices
!-----------------------------------------------------------------------------------------
!-----------------------------------------------------------------------------------------

!init plane wave coeff counter
 icg = 0
!init plane wave counter
 ikg = 0
!init occupation/band counter
 iocc = 1
 
!rspace point, cartesian direction, spin pol=x,y,z
 ABI_ALLOCATE(spincurrent,(dtset%ngfft(4),dtset%ngfft(5),dtset%ngfft(6),3,3))
 spincurrent = zero

 ABI_ALLOCATE(dummy_denpot,(cplex*dtset%ngfft(4),dtset%ngfft(5),dtset%ngfft(6)))

 ABI_ALLOCATE(gbound,(2*dtset%mgfft+8,2))

!allocate (density_matrix(2,dtset%ngfft(1)*dtset%ngfft(2)*dtset%ngfft(3),dtset%nspinor,&
!&                           dtset%ngfft(1)*dtset%ngfft(2)*dtset%ngfft(3),dtset%nspinor))
!density_matrix= zero
 ABI_ALLOCATE(density,(2,dtset%ngfft(1)*dtset%ngfft(2)*dtset%ngfft(3),dtset%nspinor,dtset%nspinor))
 density= zero

 ABI_ALLOCATE(dpsidr,(2,dtset%ngfft(4),dtset%ngfft(5),dtset%ngfft(6),dtset%nspinor,3))
 ABI_ALLOCATE(psi_r,(2,dtset%ngfft(4),dtset%ngfft(5),dtset%ngfft(6),dtset%nspinor))

!loop over kpoints
 do ikpt=1,dtset%nkpt


!  number of plane waves for this kpt
   npw = hdr%npwarr(ikpt)

!  allocate arrays dep on number of pw
   ABI_ALLOCATE(kg_k,(3,npw))
   ABI_ALLOCATE(gpsi,(2,npw,dtset%nspinor,3))
   ABI_ALLOCATE(psi,(2,npw,dtset%nspinor))
   ABI_ALLOCATE(kgcart,(3,npw))

!  get cartesian coordinates of k+G vectors around this kpoint
   do ig=1,npw
     kgcart(:,ig) = matmul(gprimd(:,:),dtset%kpt(:,ikpt)+kg(:,ikg+ig))
     kg_k (:,ig) = kg(:,ikg+ig)
   end do

!  get gbound
   call sphereboundary(gbound,dtset%istwfk(ikpt),kg_k,dtset%mgfft,npw)

!  loop over bands
   do iband=1,dtset%nband(ikpt)

!    prefactor for sum over bands and kpoints
     prefact_nk = hdr%occ(iocc) * dtset%wtk(ikpt)

!    initialize this wf
     gpsi=zero
     psi=zero
     psi(:,1:npw,1) = cg(:,icg+1:icg+npw)

!    multiply psi by - i 2 pi G
     do ig=1,npw
       gpsi(1,ig,:,1) =  two_pi * kgcart(1,ig)*psi(2,ig,:) 
       gpsi(2,ig,:,1) = -two_pi * kgcart(1,ig)*psi(1,ig,:) 
       gpsi(1,ig,:,2) =  two_pi * kgcart(2,ig)*psi(2,ig,:) 
       gpsi(2,ig,:,2) = -two_pi * kgcart(2,ig)*psi(1,ig,:) 
       gpsi(1,ig,:,3) =  two_pi * kgcart(3,ig)*psi(2,ig,:) 
       gpsi(2,ig,:,3) = -two_pi * kgcart(3,ig)*psi(1,ig,:) 
     end do

!    loop over spinorial components
     do ispinor=1,dtset%nspinor
!      FT Gpsi_x to real space
       call fourwf(cplex,dummy_denpot,gpsi(:,:,ispinor,1),dummy_fofgout,&
&       dpsidr(:,:,:,:,ispinor,1),gbound,gbound,&
&       hdr%istwfk(ikpt),kg_k,kg_k,dtset%mgfft,mpi_enreg,1,dtset%ngfft,npw,&
&       npw,dtset%ngfft(4),dtset%ngfft(5),dtset%ngfft(6),&
&       fft_option,dtset%paral_kgb,0,one,one,use_gpu_cuda=dtset%use_gpu_cuda)

!      FT Gpsi_y to real space
       call fourwf(cplex,dummy_denpot,gpsi(:,:,ispinor,2),dummy_fofgout,&
&       dpsidr(:,:,:,:,ispinor,2),gbound,gbound,&
&       hdr%istwfk(ikpt),kg_k,kg_k,dtset%mgfft,mpi_enreg,1,dtset%ngfft,npw,&
&       npw,dtset%ngfft(4),dtset%ngfft(5),dtset%ngfft(6),&
&       fft_option,dtset%paral_kgb,0,one,one,use_gpu_cuda=dtset%use_gpu_cuda)

!      FT Gpsi_z to real space
       call fourwf(cplex,dummy_denpot,gpsi(:,:,ispinor,3),dummy_fofgout,&
&       dpsidr(:,:,:,:,ispinor,3),gbound,gbound,&
&       hdr%istwfk(ikpt),kg_k,kg_k,dtset%mgfft,mpi_enreg,1,dtset%ngfft,npw,&
&       npw,dtset%ngfft(4),dtset%ngfft(5),dtset%ngfft(6),&
&       fft_option,dtset%paral_kgb,0,one,one,use_gpu_cuda=dtset%use_gpu_cuda)

!      FT psi to real space
       call fourwf(cplex,dummy_denpot,psi(:,:,ispinor),dummy_fofgout,&
&       psi_r(:,:,:,:,ispinor),gbound,gbound,&
&       hdr%istwfk(ikpt),kg_k,kg_k,dtset%mgfft,mpi_enreg,1,dtset%ngfft,npw,&
&       npw,dtset%ngfft(4),dtset%ngfft(5),dtset%ngfft(6),&
&       fft_option,dtset%paral_kgb,0,one,one,use_gpu_cuda=dtset%use_gpu_cuda)

     end do ! ispinor

!    dpsidr now contains the full derivative of psi wrt space (gradient) in cartesian coordinates

!    get 3 pauli matrix contributions to the current: x,y,z, cart dir, spin dir
     do icartdir=1,3

!      x pauli spin matrix 
!      sigma_x =  | 0   1 |
!      | 1   0 |
       spincurrent(:,:,:,icartdir,1) =  spincurrent(:,:,:,icartdir,1) + prefact_nk * &
!      Re(psi_r(up)^* dpsidr(down))
&       real(psi_r(1,:,:,:,1)*dpsidr(1,:,:,:,2,icartdir)  &
&       + psi_r(2,:,:,:,1)*dpsidr(2,:,:,:,2,icartdir)  &
!      Re(psi_r(down)^* dpsidr(up))
&       + psi_r(1,:,:,:,2)*dpsidr(1,:,:,:,1,icartdir)  &
&       + psi_r(2,:,:,:,2)*dpsidr(2,:,:,:,1,icartdir))

!      y pauli spin matrix
!      sigma_y =  | 0  -i |
!      | i   0 |
       spincurrent(:,:,:,icartdir,2) =  spincurrent(:,:,:,icartdir,2) + prefact_nk * &
!      Re(-i psi_r(up)^* dpsidr(down))
&       real(psi_r(1,:,:,:,1)*dpsidr(2,:,:,:,2,icartdir)  &
&       - psi_r(2,:,:,:,1)*dpsidr(1,:,:,:,2,icartdir)  &
!      Re(i psi_r(down)^* dpsidr(up))
&       - psi_r(1,:,:,:,2)*dpsidr(2,:,:,:,1,icartdir)  &
&       + psi_r(2,:,:,:,2)*dpsidr(1,:,:,:,1,icartdir))

!      z pauli spin matrix
!      sigma_z =  | 1   0 |
!      | 0  -1 |
       spincurrent(:,:,:,icartdir,3) =  spincurrent(:,:,:,icartdir,3) + prefact_nk * &
!      Re(psi_r(up)^* dpsidr(up))
&       real(psi_r(1,:,:,:,1)*dpsidr(1,:,:,:,1,icartdir)  &
&       - psi_r(2,:,:,:,1)*dpsidr(2,:,:,:,1,icartdir)  &
!      Re(-psi_r(down)^* dpsidr(down))
&       - psi_r(1,:,:,:,2)*dpsidr(1,:,:,:,2,icartdir)  &
&       + psi_r(2,:,:,:,2)*dpsidr(2,:,:,:,2,icartdir))
     end do ! end icartdir

!    
!    accumulate non local density matrix in real space
!    NOTE: if we are only using the local part of the current, this becomes the
!    density spinor matrix! (much lighter to calculate) rho(r, sigma, sigmaprime)
!    
     do ispinor=1,dtset%nspinor
       do i3=1,dtset%ngfft(3)
         do i2=1,dtset%ngfft(2)
           do i1=1,dtset%ngfft(1)
             irealsp = i1 + (i2-1)*dtset%ngfft(1) + (i3-1)*dtset%ngfft(2)*dtset%ngfft(1)

             do ispinorp=1,dtset%nspinor
               density(1,irealsp,ispinor,ispinorp) = &
&               density(1,irealsp,ispinor,ispinorp) + &
&               prefact_nk * (psi_r(1,i1,i2,i3,ispinor)*psi_r(1,i1,i2,i3,ispinorp)&
&               +  psi_r(2,i1,i2,i3,ispinor)*psi_r(2,i1,i2,i3,ispinorp))
               density(2,irealsp,ispinor,ispinorp) = &
&               density(2,irealsp,ispinor,ispinorp) + &
&               prefact_nk * (psi_r(1,i1,i2,i3,ispinor)*psi_r(2,i1,i2,i3,ispinorp)&
&               -  psi_r(2,i1,i2,i3,ispinor)*psi_r(1,i1,i2,i3,ispinorp))

!              do i3p=1,dtset%ngfft(3)
!              do i2p=1,dtset%ngfft(2)
!              do i1p=1,dtset%ngfft(1)
!              irealsp_p = i1p + (i2p-1)*dtset%ngfft(1) + (i3p-1)*dtset%ngfft(2)*dtset%ngfft(1)
!              
!              NOTE : sign changes in second terms below because rho = psi*(r) psi(rprime)
!              
!              density_matrix(1,irealsp,ispinor,irealsp_p,ispinorp) = &
!              &           density_matrix(1,irealsp,ispinor,irealsp_p,ispinorp) + &
!              &           prefact_nk * (psi_r(1,i1,i2,i3,ispinor)*psi_r(1,i1p,i2p,i3p,ispinorp)&
!              &           +  psi_r(2,i1,i2,i3,ispinor)*psi_r(2,i1p,i2p,i3p,ispinorp))
!              density_matrix(2,irealsp,ispinor,irealsp_p,ispinorp) = &
!              &           density_matrix(2,irealsp,ispinor,irealsp_p,ispinorp) + &
!              &           prefact_nk * (psi_r(1,i1,i2,i3,ispinor)*psi_r(2,i1p,i2p,i3p,ispinorp)&
!              &           -  psi_r(2,i1,i2,i3,ispinor)*psi_r(1,i1p,i2p,i3p,ispinorp))
!              end do
!              end do
!              end do ! end irealspprime

             end do !end ispinorp do
             
           end do
         end do
       end do ! end irealsp
     end do !end ispinor do

!    update pw counter
     icg=icg+npw
     iocc=iocc+1
   end do ! iband

   ikg=ikg+npw

!  deallocate arrays dep on npw for this kpoint
   ABI_DEALLOCATE(kg_k)
   ABI_DEALLOCATE(gpsi)
   ABI_DEALLOCATE(psi)
   ABI_DEALLOCATE(kgcart)

 end do ! ikpt

 ABI_DEALLOCATE(dpsidr)
 ABI_DEALLOCATE(psi_r)
 ABI_DEALLOCATE(dummy_denpot)
 ABI_DEALLOCATE(gbound)

!prefactor for contribution to spin current
!prefactor is 1/2 * 1/2 * 2 Re(.):
!1/2 from the formula for the current
!1/2 from the use of the normalized Pauli matrices
!2 from the complex conjugate part 
!total = 1/2
 spincurrent = half * spincurrent

!make array of positions for all points on grid
 ABI_ALLOCATE(position_op,(3,dtset%ngfft(1),dtset%ngfft(2),dtset%ngfft(3)))
 do i3=1,dtset%ngfft(3)
   do i2=1,dtset%ngfft(2)
     do i1=1,dtset%ngfft(1)
       position_op(:,i1,i2,i3) = matmul(hdr%rprimd,(/i1-one,i2-one,i3-one/))&
&       /(/dtset%ngfft(1),dtset%ngfft(2),dtset%ngfft(3)/)
     end do
   end do 
 end do

!-----------------------------------------------------------------------------------------
!-----------------------------------------------------------------------------------------
!add electric field term to current. Non local term in case of pseudopotential SO
!present theory is that it is equal to A(r,r') = (W_SO(r,r') + W_SO(r',r))
!For the strictly local part of the current, this becomes 2 W_SO(r,r)
!
!W_SO is the prefactor in the spinorbit part of the potential, such that it
!can be written V_SO = W_SO . p (momentum operator)
!decomposed from V_SO = v_SO(r,r') L.S = v_SO(r,r') (rxp).S = v_SO(r,r') (Sxr).p
!and ensuring symmetrization for the r operator wrt the two arguments of v_SO(r,r')
!Hence:
!W_SO(r,r) = v_SO(r,r) (Sxr)
!-----------------------------------------------------------------------------------------
!-----------------------------------------------------------------------------------------

!allocate (vso_realspace_nl(2,dtset%ngfft(1)*dtset%ngfft(2)*dtset%ngfft(3),dtset%nspinor,&
!& dtset%ngfft(1)*dtset%ngfft(2)*dtset%ngfft(3),dtset%nspinor))

!call vso_realspace_nonlop(atindx,atindx1,dtfil,dtset,gmet,gprimd,hdr,kg,&
!& mpi_enreg,nattyp,ph1d,position_op,psps,rmet,ucvol,vso_realspace_nl,ylm,ylmgr)
!anticommutator of VSO with position operator
!--- not needed in local spin current case ---

 ABI_ALLOCATE(vso_realspace,(2,dtset%ngfft(1)*dtset%ngfft(2)*dtset%ngfft(3),dtset%nspinor,dtset%nspinor,3))

 call vso_realspace_local(dtset,hdr,position_op,psps,vso_realspace)


!multiply by density (or density matrix for nonlocal case)
!and add to spin current
 


 ABI_DEALLOCATE(density)

 realrecip = 0 ! real space for xsf output
 ABI_ALLOCATE(xcart,(3,dtset%natom))
 call xredxcart(dtset%natom,1,hdr%rprimd,xcart,hdr%xred)

!-----------------------------------------------------------------------------------------
!-----------------------------------------------------------------------------------------
!output 3 components of current for each real space point
!-----------------------------------------------------------------------------------------
!-----------------------------------------------------------------------------------------
 do ispindir=1, 3
!  choose rescale_current such that the maximum current component printed out
!  is 1 percent of lattice distance
!  By default XCrysDen multiplies by 200 to get something comparable to a distance in real space.
   rescale_current = maxval(abs(spincurrent(:, :, :, :, ispindir)))
   if (abs(rescale_current) < tol8) then
     rescale_current = one
   else
     rescale_current = 0.001_dp * sqrt(max(sum(hdr%rprimd(:,1)**2), &
&     sum(hdr%rprimd(:,2)**2), sum(hdr%rprimd(:,3)**2)))
   end if

   filnam=trim(dtfil%fnameabo_spcur)//spin_symbol(ispindir)//".xsf"
   spcur_unit=200
   open (file=filnam,unit=spcur_unit,status='unknown',iostat=iost)
   if (iost /= 0) then
     write (message,'(2a)')' spin_current: ERROR- opening file ',trim(filnam)
     call wrtout(std_out,message,'COLL')
     call leave_new('COLL')
   end if
   
!  print header
   write (spcur_unit,'(a)')          '#'
   write (spcur_unit,'(a)')          '#  Xcrysden format file'
   write (spcur_unit,'(a)')          '#  spin current density, for all real space points'
   write (spcur_unit,'(a,3(I5,1x))') '#  fft grid is ', dtset%ngfft(1), dtset%ngfft(2), dtset%ngfft(3)
   write (spcur_unit,'(a,a,a)')  '# ', spin_symbol(ispindir), '-spin current, full vector '

   write (spcur_unit,'(a)')  'ATOMS'
   do iatom = 1, dtset%natom
     write (spcur_unit,'(I4, 2x, 3(E16.6, 1x))') int(dtset%znucl(dtset%typat(iatom))), xcart(:,iatom)
   end do

   do i3=1,dtset%ngfft(3)
     do i2=1,dtset%ngfft(2)
       do i1=1,dtset%ngfft(1)
         write (spcur_unit,'(a, 3(E10.3),2x, 3(E20.10))') 'X ', &
&         position_op(:, i1, i2, i3), spincurrent(i1, i2, i3, :, ispindir)*rescale_current
       end do
     end do 
   end do
   close (spcur_unit)

 end do ! end ispindir

!-----------------------------------------------------------------------------------------
!-----------------------------------------------------------------------------------------
!output 3 spin components of V_SO matrices, for each real space point
!-----------------------------------------------------------------------------------------
!-----------------------------------------------------------------------------------------
 do ispindir=1,3
   do icplex=1,2
     do ispinor=1,dtset%nspinor
       do ispinorp=1,dtset%nspinor

!        for the moment only print out if non zero
         if (abs(sum(vso_realspace(icplex, :, ispinor, ispinorp, ispindir))) < tol8) cycle

         filnam=trim(dtfil%fnameabo_vso)//"_spin_"//spin_symbol(ispindir)//"_"//&
&         spinor_sym(ispinor)//spinor_sym(ispinorp)//"_"//realimag(icplex)//".xsf"
         spcur_unit=200
         open (file=filnam,unit=spcur_unit,status='unknown',iostat=iost)
         if (iost /= 0) then
           write (message,'(2a)')' spin_current: ERROR- opening file ',trim(filnam)
           call wrtout(std_out,message,'COLL')
           call leave_new('COLL')
         end if

!        print header
         write (spcur_unit,'(a)')        '#'
         write (spcur_unit,'(a)')        '#  Xcrysden format file'
         write (spcur_unit,'(a)')        '#  spin-orbit potential (space diagonal), for all real space points'
         write (spcur_unit,'(a)')        '#    Real part first, then imaginary part'
         write (spcur_unit,'(a,3(I5,1x))') '#  fft grid is ', dtset%ngfft(1), dtset%ngfft(2),   dtset%ngfft(3)
         write (spcur_unit,'(a,a,a)')    '# ', spin_symbol(ispindir), '-spin contribution '
         write (spcur_unit,'(a,a,a)')    '# ', spinor_sym(ispinor)//spinor_sym(ispinorp), '-spin element of the spinor 2x2 matrix '
         
         write (spcur_unit,'(a,a)')      '#  cart x     *  cart y    *  cart z    ***',&
&         ' up-up component    *  up-down           * down-up          * down-down          '


         call printxsf(dtset%ngfft(1),dtset%ngfft(2),dtset%ngfft(3),&
&         vso_realspace(icplex, :, ispinor, ispinorp, ispindir),&
&         hdr%rprimd,(/zero,zero,zero/), dtset%natom, dtset%ntypat, &
&         dtset%typat, xcart, dtset%znucl, spcur_unit,realrecip)


!        
!        NOTE: have chosen actual dims of grid (n123) instead of fft box, for which n45
!        may be different
!        
!        do i3_dum=1,dtset%ngfft(3)+1
!        i3 = mod(i3_dum-1,dtset%ngfft(3)) + 1 
!        do i2_dum=1,dtset%ngfft(2)+1
!        i2 = mod(i2_dum-1,dtset%ngfft(2)) + 1 
!        do i1_dum=1,dtset%ngfft(1)+1
!        i1 = mod(i1_dum-1,dtset%ngfft(1)) + 1 
!        
!        irealsp = i1 + (i2-1)*dtset%ngfft(1) + (i3-1)*dtset%ngfft(2)*dtset%ngfft(1)
!        write (spcur_unit,'(E20.10,1x)')&
!        &      vso_realspace(icplex,irealsp,  ispinor, ispinorp, ispindir)
!        end do
!        end do
!        end do

         close (spcur_unit)

       end do ! ispinorp
     end do ! ispinor
   end do ! icplex
 end do ! end ispindir
 

 ABI_DEALLOCATE(vso_realspace)
!deallocate (vso_realspace_nl)
 ABI_DEALLOCATE(position_op)
 ABI_DEALLOCATE(spincurrent)

 write(std_out,*) ' Exiting subroutine spin_current '

end subroutine spin_current


!!***
