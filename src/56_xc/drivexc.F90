!{\src2tex{textfont=tt}}
!!****f* ABINIT/drivexc
!! NAME
!! drivexc
!!
!! FUNCTION
!! Driver of XC functionals.
!! Treat spin-polarized as well as non-spin-polarized.
!! Treat local approximations or GGAs.
!! Optionally, deliver the XC kernel, or even the derivative
!! of the XC kernel (the third derivative of the XC energy)
!!
!!
!! COPYRIGHT
!! Copyright (C) 2002-2012 ABINIT group (XG)
!! This file is distributed under the terms of the
!! GNU General Public License, see ~abinit/COPYING
!! or http://www.gnu.org/copyleft/gpl.txt .
!! For the initials of contributors, see ~abinit/doc/developers/contributors.txt .
!!
!! INPUTS
!!  ixc=number of the XC functional
!!   (to be described)
!!  ndvxc= size of dvxc(npts,ndvxc)
!!  ngr2= size of grho2_updn(npts,ngr2)
!!  nvxcgrho= size of vxcgrho(npts,nvxcgrho)
!!  npts=number of real space points on which the density
!!   (and its gradients, if needed) is provided
!!  nspden=number of spin-density components (1 or 2)
!!  order=gives the maximal derivative of Exc computed.
!!    1=usual value (return exc and vxc)
!!    2=also computes the kernel (return exc,vxc,kxc)
!!   -2=like 2, except (to be described)
!!    3=also computes the derivative of the kernel (return exc,vxc,kxc,k3xc)
!!  rho_updn(npts,nspden)=the spin-up and spin-down densities
!!    If nspden=1, only the spin-up density must be given.
!!    In the calling routine, the spin-down density must
!!    be equal to the spin-up density,
!!    and both are half the total density.
!!    If nspden=2, the spin-up and spin-down density must be given
!!  Optional inputs :
!!  exexch= choice of local exact exchange. Active if exexch=3
!!  grho2_updn(npts,ngr2)=the square of the gradients of
!!    spin-up, spin-down, and total density
!!    If nspden=1, only the square of the gradient of the spin-up density
!!     must be given. In the calling routine, the square of the gradient
!!     of the spin-down density
!!     must be equal to the square of the gradient of the spin-up density,
!!     and both must be equal to one-quarter of the square of the
!!     gradient of the total density.
!!    If nspden=2, the square of the gradients of
!!     spin-up, spin-down, and total density must be given.
!!     Note that the square of the gradient of the total
!!     density is usually NOT related to the square of the
!!     gradient of the spin-up and spin-down densities,
!!     because the gradients are not usually aligned.
!!     This is not the case when nspden=1.
!!  lrho_updn(npts,nspden)=the Laplacian of spin-up and spin-down densities
!!    If nspden=1, only the spin-up Laplacian density must be given.
!!    In the calling routine, the spin-down Laplacian density must
!!    be equal to the spin-up Laplacian density,
!!    and both are half the total Laplacian density.
!!    If nspden=2, the Laplacian of spin-up and spin-down densities must be given
!!  tau_updn(npts,nspden)=the spin-up and spin-down kinetic energy densities
!!    If nspden=1, only the spin-up kinetic energy density must be given.
!!    In the calling routine, the spin-down kinetic energy density must
!!    be equal to the spin-up kinetic energy density,
!!    and both are half the total kinetic energy density.
!!    If nspden=2, the spin-up and spin-down kinetic energy densities must be given
!!
!! OUTPUT
!!  exc(npts)=exchange-correlation energy density (hartree)
!!  vxcrho(npts,nspden)= (d($\rho$*exc)/d($\rho_up$)) (hartree)
!!                  and  (d($\rho$*exc)/d($\rho_down$)) (hartree)
!!  vxcgrho(npts,3)= 1/$|grad \rho_up|$ (d($\rho$*exc)/d($|grad \rho_up|$)) (hartree)
!!                   1/$|grad \rho_dn|$ (d($\rho$*exc)/d($|grad \rho_dn|$)) (hartree)
!!              and  1/$|grad \rho|$ (d($\rho$*exc)/d($|grad \rho|$))       (hartree)
!!     (will be zero if a LDA functional is used)
!!  vxclrho(npts,nspden)=(only for meta-GGA, i.e. optional output)=
!!                       (d($\rho$*exc)/d($\lrho_up$))   (hartree)
!!                  and  (d($\rho$*exc)/d($\lrho_down$)) (hartree)
!!  vxctau(npts,nspden)=(only for meta-GGA, i.e. optional output)=
!!    derivative of XC energy density with respect to kinetic energy density (depsxcdtau).
!!                       (d($\rho$*exc)/d($\tau_up$))    (hartree) 
!!                  and  (d($\rho$*exc)/d($\tau_down$))  (hartree) 
!!  Optional output :
!!  if(abs(order)>1)
!!   dvxc=partial second derivatives of the xc energy, only if abs(order)>1
!!   (This is a mess, to be rationalized !!)
!!   In case of local energy functional (option=1,-1 or 3):
!!    dvxc(npts,1+nspden)=              (Hartree*bohr^3)
!!     if(nspden=1 .and. order==2): dvxci(:,1)=dvxc/d$\rho$ , dvxc(:,2) empty
!!     if(nspden=1 .and. order==-2): also compute dvxci(:,2)=dvxc($\uparrow$)/d$\rho(\downarrow)$
!!     if(nspden=2): dvxc(:,1)=dvxc($\uparrow$)/d$\rho(\downarrow)$,
!!                   dvxc(:,2)=dvxc($\uparrow$)/d$\rho(\downarrow)$,
!!                   dvxc(:,3)=dvxc($\downarrow$)/d$\rho(\downarrow)$
!!   In case of gradient corrected functional (option=2,-2, 4, -4, 5, 6, 7):
!!    dvxc(npts,15)=
!!     dvxc(:,1)= d2Ex/drho_up drho_up
!!     dvxc(:,2)= d2Ex/drho_dn drho_dn
!!     dvxc(:,3)= dEx/d(abs(grad(rho_up))) / abs(grad(rho_up))
!!     dvxc(:,4)= dEx/d(abs(grad(rho_dn))) / abs(grad(rho_dn))
!!     dvxc(:,5)= d2Ex/d(abs(grad(rho_up))) drho_up / abs(grad(rho_up))
!!     dvxc(:,6)= d2Ex/d(abs(grad(rho_dn))) drho_dn / abs(grad(rho_dn))
!!     dvxc(:,7)= 1/abs(grad(rho_up)) * d/d(abs(grad(rho_up)) (dEx/d(abs(grad(rho_up))) /abs(grad(rho_up)))
!!     dvxc(:,8)= 1/abs(grad(rho_dn)) * d/d(abs(grad(rho_dn)) (dEx/d(abs(grad(rho_dn))) /abs(grad(rho_dn)))
!!     dvxc(:,9)= d2Ec/drho_up drho_up
!!     dvxc(:,10)=d2Ec/drho_up drho_dn
!!     dvxc(:,11)=d2Ec/drho_dn drho_dn
!!     dvxc(:,12)=dEc/d(abs(grad(rho))) / abs(grad(rho))
!!     dvxc(:,13)=d2Ec/d(abs(grad(rho))) drho_up / abs(grad(rho))
!!     dvxc(:,14)=d2Ec/d(abs(grad(rho))) drho_dn / abs(grad(rho))
!!     dvxc(:,15)=1/abs(grad(rho)) * d/d(abs(grad(rho)) (dEc/d(abs(grad(rho))) /abs(grad(rho)))
!!
!!   if(abs(order)>2)  (only available for LDA and nspden=1)
!!    if nspden=1 d2vxc(npts,1)=second derivative of the XC potential=3rd order derivative of energy
!!    if nspden=2 d2vxc(npts,1), d2vxc(npts,2), d2vxc(npts,3), d2vxc(npts,4) (3rd derivative of energy)
!!
!! PARENTS
!!      pawxc,pawxcsph,rhohxc
!!
!! CHILDREN
!!      invcb,leave_new,libxc_functionals_getvxc,wrtout,xchcth,xchelu,xclb
!!      xcpbe,xcpzca,xcspol,xctetr,xcwign,xcxalp
!!
!! SOURCE

#if defined HAVE_CONFIG_H
#include "config.h"
#endif

#include "abi_common.h"

subroutine drivexc(exc,ixc,npts,nspden,order,rho_updn,vxcrho,ndvxc,ngr2,nd2vxc,nvxcgrho,   & !Mandatory arguments
&                  dvxc,d2vxc,grho2_updn,vxcgrho,exexch,lrho_updn,vxclrho,tau_updn,vxctau)    !Optional arguments

 use m_profiling

 use defs_basis
#if defined HAVE_DFT_LIBXC
 use libxc_functionals
#endif

!This section has been created automatically by the script Abilint (TD).
!Do not modify the following lines by hand.
#undef ABI_FUNC
#define ABI_FUNC 'drivexc'
 use interfaces_14_hidewrite
 use interfaces_16_hideleave
 use interfaces_56_xc, except_this_one => drivexc
!End of the abilint section

 implicit none

!Arguments ------------------------------------
!scalars
 integer,intent(in) :: ixc,ndvxc,ngr2,nd2vxc,npts,nspden,nvxcgrho,order
 integer,intent(in),optional :: exexch
!arrays
 real(dp),intent(in) :: rho_updn(npts,nspden)
 real(dp),intent(in),optional :: grho2_updn(npts,ngr2)
 real(dp),intent(in),optional :: lrho_updn(npts,nspden), tau_updn(npts,nspden)
 real(dp),intent(out) :: exc(npts),vxcrho(npts,nspden)
 real(dp),intent(out),optional :: d2vxc(npts,nd2vxc),dvxc(npts,ndvxc)
 real(dp),intent(out),optional :: vxcgrho(npts,nvxcgrho)
 real(dp),intent(out),optional :: vxclrho(npts,nspden),vxctau(npts,nspden)


!Local variables-------------------------------
!scalars
 integer :: ixc1,ixc2,i_all,optpbe,ispden
!integer :: jj,kk
!real(dp) :: sum
 real(dp) :: alpha
 real(dp),parameter :: rsfac=0.6203504908994000e0_dp
 character(len=500) :: message
!arrays
 real(dp),allocatable :: exci_rpa(:)
 real(dp),allocatable :: rhotot(:),rspts(:),vxci_rpa(:,:),zeta(:)
!no_abirules
!real(dp),allocatable :: d2vxci(:,:),dvxci(:,:),grho2_updn_fake(:,:)

!  *************************************************************************

!DEBUG
!write(std_out,*)'-> drivexc : enter'
!write(std_out,*)'++++++++++++++++++'
!write(std_out,*) 'ixc',ixc
!write(std_out,*) 'npts',npts
!write(std_out,*) 'nspden',nspden
!write(std_out,*) 'order',order
!sum=0.0
!do jj=1,nspden
!do kk=1,npts
!sum=sum+abs(rho_updn(kk,jj))
!end do
!end do
!write(std_out,*) 'SUM(rho_updn)',sum
!write(std_out,*) 'ndvxc',ndvxc
!ENDDEBUG

!Checks the values of order
 if( (order<1 .and. order/=-2) .or. order>4)then
   write(message, '(a,a,a,a,i6,a)' )ch10,&
&   ' drivexc : BUG -',ch10,&
&   '  The only allowed values for order are 1,2, -2, or 3, while it is found to be ',order,'.'
   call wrtout(std_out,message,'COLL')
   call leave_new('COLL')
 end if


!Checks the compatibility between the inputs and the presence of the optional arguments

 if(present(dvxc))then
   if(order**2 <= 1 .or. ixc==16 .or. ixc==17 .or. ixc==26 .or. ixc==27 )then
     write(message, '(8a,i6,a,i6)' )ch10,&
&     ' drivexc : BUG -',ch10,&
&     '  The value of the number of the XC functional ixc',ch10,&
&     '  or the value of order is not compatible with the presence of the array dvxc',ch10,&
&     '  ixc=',ixc,'order=',order
     call wrtout(std_out,message,'COLL')
     call leave_new('COLL')
   end if
 end if

 if(present(d2vxc))then
   if(order /= 3 .or. (ixc /= 3 .and.  (((ixc > 15) .and. (ixc /=23)) .or.&
&   (ixc >= 0 .and. ixc < 7))) )then
     write(message, '(8a,i6,a,i6)' )ch10,&
&     ' drivexc : BUG -',ch10,&
&     '  The value of the number of the XC functional ixc',ch10,&
&     '  or the value of order is not compatible with the presence of the array d2vxc',ch10,&
&     '  ixc=',ixc,'order=',order
     call wrtout(std_out,message,'COLL')
     call leave_new('COLL')
   end if
 end if

 if(present(vxcgrho))then
   if(nvxcgrho == 0 .or. &
&   ((((ixc > 17 .and. ixc /= 23 .and. ixc/=24 .and. ixc/=26 .and. ixc/=27) .or.&
&   (ixc >= 0 .and. ixc < 7)) .and. nvxcgrho /=3 ))) then
     if(ixc<31 .and. ixc>34)then !! additional if to include ixc 31 to 34 in the list (these ixc are used for mgga test see below)
       write(message, '(8a,i6,a,i6)' )ch10,&
&       ' drivexc : BUG -',ch10,&
&       '  The value of the number of the XC functional ixc',ch10,&
&       '  or the value of nvxcgrho is not compatible with the presence of the array vxcgrho',ch10,&
&       '  ixc=',ixc,'  nvxcgrho=',nvxcgrho
       call wrtout(std_out,message,'COLL')
       call leave_new('COLL')
     end if
   end if
 end if

 if(present(grho2_updn))then
   if (ngr2/=2*nspden-1 ) then
     write(message, '(4a)' ) ch10,&
&     ' drivexc : BUG -',ch10,&
&     '  ngr2 must be 2*nspden-1 !'
!    call wrtout(std_out,message,'COLL')
!    call leave_new('COLL')
   end if
   if((ixc > 17 .and. ixc /= 23 .and. ixc/=24 .and. ixc/=26 .and. ixc/=27) .or. (ixc >= 0 .and. ixc < 11))then
     if(ixc<31 .and. ixc>34)then !! additional if to include ixc 31 to 34 in the list (these ixc are used for mgga test see below)
       write(message, '(8a,i6)' )ch10,&
&       ' drivexc : BUG -',ch10,&
&       '  The value of the number of the XC functional ixc',ch10,&
&       '  is not compatible with the presence of the array grho2_updn',ch10,&
&       '  ixc=',ixc
       call wrtout(std_out,message,'COLL')
       call leave_new('COLL')
     end if
   end if
 end if

!If needed, compute rhotot and rs
 if (ixc==1 .or. ixc==2 .or. ixc==3 .or. ixc==4 .or. ixc==5 .or. ixc==6 .or. &
& ixc==21 .or. ixc==22) then
   ABI_ALLOCATE(rhotot,(npts))
   i_all = ABI_ALLOC_STAT
   ABI_ALLOCATE(rspts,(npts))
   i_all = ABI_ALLOC_STAT
   if(nspden==1)then
     rhotot(:)=two*rho_updn(:,1)
   else
     rhotot(:)=rho_updn(:,1)+rho_updn(:,2)
   end if
   call invcb(rhotot,rspts,npts)
   rspts(:)=rsfac*rspts(:)
 end if
!If needed, compute zeta
 if (ixc==1 .or. ixc==21 .or. ixc==22) then
   ABI_ALLOCATE(zeta,(npts))
   i_all = ABI_ALLOC_STAT
   if(nspden==1)then
     zeta(:)=zero
   else
     zeta(:)=two*rho_updn(:,1)/rhotot(:)-one
   end if
 end if

!Default value for vxcgrho
!if (present(vxcgrho)) vxcgrho(:,:)=zero

!!! !Could be more selective in allocating arrays ...
!!! allocate(dvxci(npts,15),d2vxci(npts))

 if (ixc==0) then

   exc=zero ; vxcrho=zero
   if(present(d2vxc)) d2vxc(:,:)=zero
   if(present(dvxc)) dvxc(:,:)=zero
   if(present(vxcgrho)) vxcgrho(:,:)=zero
   if(present(vxclrho)) vxclrho(:,:)=zero
   if(present(vxctau)) vxctau(:,:)=zero

 else if (ixc==1 .or. ixc==21 .or. ixc==22) then
!  new Teter fit (4/93) to Ceperley-Alder data, with spin-pol option
   if (order**2 <= 1) then
     call xcspol(exc,npts,nspden,order,rspts,vxcrho,zeta,ndvxc)
   else
     if(ndvxc /= nspden + 1 )then
       write(message, '(10a,i6,a,i6)' )ch10,&
&       ' drivexc : BUG -',ch10,&
&       '  Wrong value of ndvxc:',ch10,&
&       '  the value of the spin polarization',ch10,&
&       '  is not compatible with the ixc',ch10,&
&       '  ixc=',ixc,'nspden=',nspden
       call wrtout(std_out,message,'COLL')
       call leave_new('COLL')
     end if
     call xcspol(exc,npts,nspden,order,rspts,vxcrho,zeta,ndvxc,dvxc)
   end if

 else if (ixc==2) then
!  Perdew-Zunger fit to Ceperly-Alder data (no spin-pol)
   if (order**2 <= 1) then
     call xcpzca(exc,npts,order,rhotot,rspts,vxcrho(:,1))
   else
     if(ndvxc /= 1 )then
       write(message, '(6a,i6,a,i6)' )ch10,&
&       ' drivexc : BUG -',ch10,&
&       '  Wrong value of ndvxc:',ch10,&
&       '  ixc=',ixc,'ndvxc=',ndvxc
       call wrtout(std_out,message,'COLL')
       call leave_new('COLL')
     end if
     call xcpzca(exc,npts,order,rhotot,rspts,vxcrho(:,1),dvxc)
   end if

 else if (ixc==3) then
!  Teter fit (4/91) to Ceperley-Alder values (no spin-pol)
   if (order**2 <= 1) then
     call xctetr(exc,npts,order,rhotot,rspts,vxcrho(:,1))
   else if (order == 2) then
     if(ndvxc /= 1 )then
       write(message, '(6a,i3,a,i3)' )ch10,&
&       ' drivexc : BUG -',ch10,&
&       '  Wrong value of ndvxc:',ch10,&
&       '  ixc=',ixc,'ndvxc=',ndvxc
       call wrtout(std_out,message,'COLL')
       call leave_new('COLL')
     end if
     call xctetr(exc,npts,order,rhotot,rspts,vxcrho(:,1),dvxc=dvxc)
   else if (order == 3) then
     if(ndvxc /= 1 )then
       write(message, '(6a,i6,a,i6)' )ch10,&
&       ' drivexc : BUG -',ch10,&
&       '  Wrong value of ndvxc:',ch10,&
&       '  ixc=',ixc,'ndvxc=',ndvxc
       call wrtout(std_out,message,'COLL')
       call leave_new('COLL')
     end if
     call xctetr(exc,npts,order,rhotot,rspts,vxcrho(:,1),d2vxc,dvxc)
   end if

 else if (ixc==4) then
!  Wigner xc (no spin-pol)
   if (order**2 <= 1) then
     call xcwign(exc,npts,order,rspts,vxcrho(:,1))
   else
     if(ndvxc /= 1 )then
       write(message, '(6a,i6,a,i6)' )ch10,&
&       ' drivexc : BUG -',ch10,&
&       '  Wrong value of ndvxc:',ch10,&
&       '  ixc=',ixc,'ndvxc=',ndvxc
       call wrtout(std_out,message,'COLL')
       call leave_new('COLL')
     end if
     call xcwign(exc,npts,order,rspts,vxcrho(:,1),dvxc)
   end if

 else if (ixc==5) then
!  Hedin-Lundqvist xc (no spin-pol)
   if (order**2 <= 1) then
     call xchelu(exc,npts,order,rspts,vxcrho(:,1))
   else
     if(ndvxc /= 1 )then
       write(message, '(6a,i6,a,i6)' )ch10,&
&       ' drivexc : BUG -',ch10,&
&       '  Wrong value of ndvxc:',ch10,&
&       '  ixc=',ixc,'ndvxc=',ndvxc
       call wrtout(std_out,message,'COLL')
       call leave_new('COLL')
     end if
     call xchelu(exc,npts,order,rspts,vxcrho(:,1),dvxc)
   end if

 else if (ixc==6) then
!  X-alpha (no spin-pol)
   if (order**2 <= 1) then
     call xcxalp(exc,npts,order,rspts,vxcrho(:,1))
   else
     if(ndvxc /= 1 )then
       write(message, '(6a,i6,a,i6)' )ch10,&
&       ' drivexc : BUG -',ch10,&
&       '  Wrong value of ndvxc:',ch10,&
&       '  ixc=',ixc,'ndvxc=',ndvxc
       call wrtout(std_out,message,'COLL')
       call leave_new('COLL')
     end if
     call xcxalp(exc,npts,order,rspts,vxcrho(:,1),dvxc)
   end if

 else if (((ixc>=7 .and. ixc<=15) .or. (ixc>=23 .and. ixc<=24)) .and. ixc/=10 .and. ixc/=13) then

!  Perdew-Wang LSD is coded in Perdew-Burke-Ernzerhof GGA, with optpbe=1
   if(ixc==7)optpbe=1
!  x-only part of Perdew-Wang
   if(ixc==8)optpbe=-1
!  Exchange + RPA correlation from Perdew-Wang
   if(ixc==9)optpbe=3
!  Perdew-Burke-Ernzerhof GGA
   if(ixc==11)optpbe=2
!  x-only part of PBE
   if(ixc==12)optpbe=-2
!  C09x exchange of V. R. Cooper
   if(ixc==24)optpbe=-4
!  revPBE of Zhang and Yang
   if(ixc==14)optpbe=5
!  RPBE of Hammer, Hansen and Norskov
   if(ixc==15)optpbe=6
!  Wu and Cohen
   if(ixc==23)optpbe=7

   if (ixc >= 7 .and. ixc <= 9) then
     if (order**2 <= 1) then
       call xcpbe(exc,npts,nspden,optpbe,order,rho_updn,vxcrho,ndvxc,ngr2,nd2vxc)
!      write(std_out,*)' drivexc : vxcrho =',vxcrho(1:2,1)
!      write(std_out,*)' drivexc : exc_LDA max =',maxval(exc(:)),' drivexc : exc_LDA min =',minval(exc(:))
     else if (order /=3) then
       if(ndvxc /= 1+nspden .or. nvxcgrho /=0)then
         write(message, '(6a,i6,a,i6,a,i6)' )ch10,&
&         ' drivexc : BUG -',ch10,&
&         '  Wrong value of ndvxc or nvxcgrho:',ch10,&
&         '  ixc=',ixc,'ndvxc=',ndvxc,'nvxcgrho=',nvxcgrho
         call wrtout(std_out,message,'COLL')
         call leave_new('COLL')
       end if
       call xcpbe(exc,npts,nspden,optpbe,order,rho_updn,vxcrho,ndvxc,ngr2,nd2vxc,dvxci=dvxc)
     else if (order ==3) then
       if(ndvxc /= 1+nspden .or. nvxcgrho /=0 .or. nd2vxc /=(3*nspden-2))then
         write(message, '(6a,i6,a,i6,a,i6,a,i6)' )ch10,&
&         ' drivexc : BUG -',ch10,&
&         '  Wrong value of ndvxc or nvxcgrho or nd2vxc:',ch10,&
&         '  ixc=',ixc,'ndvxc=',ndvxc,'nvxcgrho=',nvxcgrho,'nd2vxc=',nd2vxc
         call wrtout(std_out,message,'COLL')
         call leave_new('COLL')
       end if
       call xcpbe(exc,npts,nspden,optpbe,order,rho_updn,vxcrho,ndvxc,ngr2,nd2vxc,d2vxci=d2vxc,dvxci=dvxc)
     end if

   else if ((ixc >= 11 .and. ixc <= 15) .or. (ixc>=23 .and. ixc<=24)) then
     if (order**2 <= 1) then
       call xcpbe(exc,npts,nspden,optpbe,order,rho_updn,vxcrho,ndvxc,ngr2,nd2vxc,&
&       dvxcdgr=vxcgrho,exexch=exexch,grho2_updn=grho2_updn)
     else if (order /=3) then
       if(ixc==12 .or. ixc==24)then 
         
         if( ndvxc /=8 .or. nvxcgrho /= 3)then
           write(message, '(6a,i6,a,i6,a,i6)' )ch10,&
&           ' drivexc : BUG -',ch10,&
&           '  Wrong value of ndvxc or nvxcgrho:',ch10,&
&           '  ixc=',ixc,'  ndvxc=',ndvxc,'  nvxcgrho=',nvxcgrho
           call wrtout(std_out,message,'COLL')
           call leave_new('COLL')
         end if
         call xcpbe(exc,npts,nspden,optpbe,order,rho_updn,vxcrho,ndvxc,ngr2,nd2vxc,&
&         dvxcdgr=vxcgrho,dvxci=dvxc,grho2_updn=grho2_updn)
         
       else if(ixc/=12 .or. ixc/=24) then

         if( ndvxc /=15 .or. nvxcgrho /= 3)then                                   
           write(message, '(6a,i6,a,i6,a,i6)' )ch10,&
&           ' drivexc : BUG -',ch10,&
&           '  Wrong value of ndvxc or nvxcgrho:',ch10,&
&           '  ixc=',ixc,'  ndvxc=',ndvxc,'  nvxcgrho=',nvxcgrho
           call wrtout(std_out,message,'COLL')
           call leave_new('COLL')
         end if
         call xcpbe(exc,npts,nspden,optpbe,order,rho_updn,vxcrho,ndvxc,ngr2,nd2vxc,&
&         dvxcdgr=vxcgrho,dvxci=dvxc,grho2_updn=grho2_updn)

       end if

     else if (order ==3) then
       if(ixc==12 .or. ixc==24)then 
         
         if( ndvxc /=8 .or. nvxcgrho /= 3)then
           write(message, '(6a,i6,a,i6,a,i6)' )ch10,&
&           ' drivexc : BUG -',ch10,&
&           '  Wrong value of ndvxc or nvxcgrho:',ch10,&
&           '  ixc=',ixc,'  ndvxc=',ndvxc,'  nvxcgrho=',nvxcgrho
           call wrtout(std_out,message,'COLL')
           call leave_new('COLL')
         end if
         call xcpbe(exc,npts,nspden,optpbe,order,rho_updn,vxcrho,ndvxc,ngr2,nd2vxc,&
&         d2vxci=d2vxc,dvxcdgr=vxcgrho,dvxci=dvxc,grho2_updn=grho2_updn)
         
       else if(ixc/=12 .or. ixc/=24) then

         if( ndvxc /=15 .or. nvxcgrho /= 3)then                                   
           write(message, '(6a,i6,a,i6,a,i6)' )ch10,&
&           ' drivexc : BUG -',ch10,&
&           '  Wrong value of ndvxc or nvxcgrho:',ch10,&
&           '  ixc=',ixc,'  ndvxc=',ndvxc,'  nvxcgrho=',nvxcgrho
           call wrtout(std_out,message,'COLL')
           call leave_new('COLL')
         end if
         call xcpbe(exc,npts,nspden,optpbe,order,rho_updn,vxcrho,ndvxc,ngr2,nd2vxc,&
&         d2vxci=d2vxc,dvxcdgr=vxcgrho,dvxci=dvxc,grho2_updn=grho2_updn)
       end if
     end if
   end if

!  !$
!  !$
!  !!  if(present(grho2_updn))then
!  !!   call xcpbe(vxcgrho,dvxci,exc,grho2_updn,npts,nspden,optpbe,&
!  !$&   order,rho_updn,vxcrho,d2vxci)
!  !!  else
!  !!   allocate(grho2_updn_fake(npts,2*nspden-1))
!  !!   call xcpbe(vxcgrho,dvxci,exc,grho2_updn_fake,npts,nspden,optpbe,&
!  !$&   order,rho_updn,vxcrho,d2vxci)
!  !!   deallocate(grho2_updn_fake)
!  !!  end if

 else if (ixc==10) then
!  RPA correlation from Perdew-Wang
   if (order**2 <= 1) then
     ABI_ALLOCATE(exci_rpa,(npts))
     ABI_ALLOCATE(vxci_rpa,(npts,2))
     optpbe=3
     call xcpbe(exci_rpa,npts,nspden,optpbe,order,rho_updn,vxci_rpa,ndvxc,ngr2,nd2vxc)
     optpbe=1
     call xcpbe(exc,npts,nspden,optpbe,order,rho_updn,vxcrho,ndvxc,ngr2,nd2vxc)
     exc(:)=exc(:)-exci_rpa(:)
!    PMA: second index of vxcrho is nspden while that of rpa is 2 they can mismatch
     vxcrho(:,1:min(nspden,2))=vxcrho(:,1:min(nspden,2))-vxci_rpa(:,1:min(nspden,2))
     ABI_DEALLOCATE(exci_rpa)
     ABI_DEALLOCATE(vxci_rpa)
   else if (order /=3) then
     if(ndvxc /= 1+nspden .or. nvxcgrho /= 0)then
       write(message,'(6a,i6,a,i6,a,i6)' )ch10,&
&       ' drivexc : BUG -',ch10,&
&       '  Wrong value of ndvxc or nvxcgrho:',ch10,&
&       '  ixc=',ixc,'ndvxc=',ndvxc,'nvxcgrho=',nvxcgrho
       call wrtout(std_out,message,'COLL')
       call leave_new('COLL')
     end if
     ABI_ALLOCATE(exci_rpa,(npts))
     ABI_ALLOCATE(vxci_rpa,(npts,2))
     optpbe=3
     call xcpbe(exci_rpa,npts,nspden,optpbe,order,rho_updn,vxci_rpa,ndvxc,ngr2,nd2vxc,dvxci=dvxc)
     optpbe=1
     call xcpbe(exc,npts,nspden,optpbe,order,rho_updn,vxcrho,ndvxc,ngr2,nd2vxc,dvxci=dvxc)
     exc(:)=exc(:)-exci_rpa(:)
     vxcrho(:,:)=vxcrho(:,:)-vxci_rpa(:,:)
     ABI_DEALLOCATE(exci_rpa)
     ABI_DEALLOCATE(vxci_rpa)
   else if (order ==3) then
     if(ndvxc /= 1+nspden .or. nvxcgrho /=0)then
       write(message,'(6a,i6,a,i6,a,i6)' )ch10,&
&       ' drivexc : BUG -',ch10,&
&       '  Wrong value of ndvxc or nvxcgrho:',ch10,&
&       '  ixc=',ixc,'ndvxc=',ndvxc,'nvxcgrho=',nvxcgrho
       call wrtout(std_out,message,'COLL')
       call leave_new('COLL')
     end if
     ABI_ALLOCATE(exci_rpa,(npts))
     ABI_ALLOCATE(vxci_rpa,(npts,2))
     optpbe=3
     call xcpbe(exci_rpa,npts,nspden,optpbe,order,rho_updn,vxci_rpa,ndvxc,ngr2,nd2vxc,&
&     d2vxci=d2vxc,dvxci=dvxc)
     optpbe=1
     call xcpbe(exc,npts,nspden,optpbe,order,rho_updn,vxcrho,ndvxc,ngr2,nd2vxc,&
&     d2vxci=d2vxc,dvxci=dvxc)
     exc(:)=exc(:)-exci_rpa(:)
     vxcrho(:,:)=vxcrho(:,:)-vxci_rpa(:,:)
     ABI_DEALLOCATE(exci_rpa)
     ABI_DEALLOCATE(vxci_rpa)
   end if

 else if(ixc==13) then
!  LDA xc energy like ixc==7, and Leeuwen-Baerends GGA xc potential
   if (order**2 <= 1) then
     optpbe=1
     call xcpbe(exc,npts,nspden,optpbe,order,rho_updn,vxcrho,ndvxc,ngr2,nd2vxc)
     call xclb(grho2_updn,npts,nspden,rho_updn,vxcrho)
   else if (order /=3) then
     if(ndvxc /= 1+nspden .or. nvxcgrho /= 0)then
       write(message, '(6a,i6,a,i6,a,i6)' )ch10,&
&       ' drivexc : BUG -',ch10,&
&       '  Wrong value of ndvxc or nvxcgrho:',ch10,&
&       '  ixc=',ixc,'ndvxc=',ndvxc,'nvxcgrho=',nvxcgrho
       call wrtout(std_out,message,'COLL')
       call leave_new('COLL')
     end if
     optpbe=1
     call xcpbe(exc,npts,nspden,optpbe,order,rho_updn,vxcrho,ndvxc,ngr2,nd2vxc,dvxci=dvxc)
     call xclb(grho2_updn,npts,nspden,rho_updn,vxcrho)
   else if (order ==3) then
     if(ndvxc /= 1+nspden .or. nvxcgrho /=0)then
       write(message, '(6a,i6,a,i6,a,i6)' )ch10,&
&       ' drivexc : BUG -',ch10,&
&       '  Wrong value of ndvxc or nvxcgrho:',ch10,&
&       '  ixc=',ixc,'ndvxc=',ndvxc,'nvxcgrho=',nvxcgrho
       call wrtout(std_out,message,'COLL')
       call leave_new('COLL')
     end if
     optpbe=1
     call xcpbe(exc,npts,nspden,optpbe,order,rho_updn,vxcrho,ndvxc,ngr2,nd2vxc,d2vxci=d2vxc,dvxci=dvxc)
     call xclb(grho2_updn,npts,nspden,rho_updn,vxcrho)
   end if

 else if(ixc==16 .or. ixc==17 .or. ixc==26 .or. ixc==27) then
   if(nvxcgrho /= 2 )then
     write(message, '(6a,i6,a,i6)' )ch10,&
&     ' drivexc : BUG -',ch10,&
&     '  Wrong value of nvxcgrho:',ch10,&
&     '  ixc=',ixc,'ndvxcdgr=',nvxcgrho
     call wrtout(std_out,message,'COLL')
     call leave_new('COLL')
   end if
   call xchcth(vxcgrho,exc,grho2_updn,ixc,npts,nspden,order,rho_updn,vxcrho)

!  only for test purpose (test various part of MGGA implementation)
 else if(ixc==31 .or. ixc==32 .or. ixc==33 .or. ixc==34) then 

   if((.not.(present(vxcgrho))) .or. (.not.(present(vxclrho))) .or. (.not.(present(vxctau))))then
     write(message, '(6a,i6,a,i6)' )ch10,&
&     ' drivexc : BUG -',ch10,&
&     '  vxcgrho or vxclrho or vxctau is not present but they are all needed for MGGA XC tests.'
     call wrtout(std_out,message,'COLL')
     call leave_new('COLL')
   end if

   exc(:)=zero
   vxcrho(:,:)=zero
   vxcgrho(:,:)=zero
   vxclrho(:,:)=zero
   vxctau(:,:)=zero

!  Perdew-Wang LSD is coded in Perdew-Burke-Ernzerhof GGA, with optpbe=1
   optpbe=1

   select case(ixc)
     case (31)
       alpha=1.00d0-(1.00d0/1.01d0)
!      Compute first LDA XC (exc,vxc) and then add fake MGGA XC (exc,vxc)
       call xcpbe(exc,npts,nspden,optpbe,order,rho_updn,vxcrho,ndvxc,ngr2,nd2vxc)
       if (nspden==1) then
!        it should be : exc_tot= exc_spin up + exc_spin down = 2*exc_spin up but this applies to tau and rho (so it cancels)
         exc(:)=exc(:)+alpha*tau_updn(:,1)/rho_updn(:,1)
       else
         do ispden=1,nspden
           exc(:)=exc(:)+alpha*tau_updn(:,ispden)/(rho_updn(:,1)+rho_updn(:,2))
         end do
       end if
       vxctau(:,:)=alpha
     case (32)
       alpha=0.01d0
!      Compute first LDA XC (exc,vxc) and then add fake MGGA XC (exc,vxc)
       call xcpbe(exc,npts,nspden,optpbe,order,rho_updn,vxcrho,ndvxc,ngr2,nd2vxc)
       if (nspden==1) then
         exc(:)=exc(:)+2.0d0*alpha*lrho_updn(:,1)
         vxcrho(:,1) =vxcrho(:,1)+2.0d0*alpha*lrho_updn(:,1)
         vxclrho(:,1)=alpha*2.0d0*rho_updn(:,1)
       else
         do ispden=1,nspden
           exc(:)=exc(:)+alpha*lrho_updn(:,ispden)
           vxcrho(:,ispden) =vxcrho(:,ispden)+alpha*(lrho_updn(:,1)+lrho_updn(:,2))
           vxclrho(:,ispden)=alpha*(rho_updn(:,1)+rho_updn(:,2))
         end do
       end if
     case (33)
       alpha=-0.010d0
!      Compute first LDA XC (exc,vxc) and then add fake MGGA XC (exc,vxc)
       call xcpbe(exc,npts,nspden,optpbe,order,rho_updn,vxcrho,ndvxc,ngr2,nd2vxc)
       if (nspden==1) then
!        it should be : exc_tot= exc_spin up + exc_spin down = 2*exc_spin up but this applies to grho2 and rho
!        (for grho2 it is a factor 4 to have total energy and for rho it is just a factor 2. So we end with factor 2 only)
         exc(:)=exc(:)+alpha*2.0d0*grho2_updn(:,1)/rho_updn(:,1)
         if(nvxcgrho==2)vxcgrho(:,1:2)=2.0d0*alpha
         if(nvxcgrho==3)vxcgrho(:,3)=2.0d0*alpha
       else
         exc(:)=exc(:)+alpha*grho2_updn(:,3)/(rho_updn(:,1)+rho_updn(:,2))
         if(nvxcgrho==2)vxcgrho(:,1:2)=2.0d0*alpha
         if(nvxcgrho==3)vxcgrho(:,3)=2.0d0*alpha
       end if
     case (34)
       alpha=-0.010d0
!      Compute first LDA XC (exc,vxc) and then add fake MGGA XC (exc,vxc)
       call xcpbe(exc,npts,nspden,optpbe,order,rho_updn,vxcrho,ndvxc,ngr2,nd2vxc)
       if (nspden==1) then
         exc(:)=exc(:)+16.0d0*alpha*tau_updn(:,1)
         vxcrho(:,1)=vxcrho(:,1)+16.0d0*alpha*tau_updn(:,1)
         vxctau(:,1)=16.0d0*alpha*rho_updn(:,1)
       else
         do ispden=1,nspden
           exc(:)=exc(:)+8.0d0*alpha*tau_updn(:,ispden)
           vxcrho(:,ispden)=vxcrho(:,ispden)+8.0d0*alpha*(tau_updn(:,1)+tau_updn(:,2))
           vxctau(:,ispden)=8.0d0*alpha*(rho_updn(:,1)+rho_updn(:,2))
         end do
       end if
   end select

 else if( ixc<0 ) then

#if defined HAVE_DFT_LIBXC

!  Check is all the necessary arrays are present and have the correct dimensions
   if (libxc_functionals_isgga() .or. libxc_functionals_ismgga()) then
     if ( (.not. present(grho2_updn)) .or. (.not. present(vxcgrho)))  then
       write(message, '(8a,i7,a,i6,a,i6)' )ch10,&
&       ' drivexc : ERROR -',ch10,&
&       '  At least one of the functionals is a GGA or a MGGA,',ch10,&
&       '  but not all the necessary arrays are present.',ch10,&
&       '  ixc=',ixc,'  nvxcgrho=',nvxcgrho,'  ngr2=',ngr2
       call wrtout(std_out,message,'COLL')
       call leave_new('COLL')
     end if

     if (ngr2==0 .or. nvxcgrho/=3) then
       write(message, '(8a,i7,a,i6,a,i6)' )ch10,&
&       ' drivexc : BUG -',ch10,&
&       '  The value of the number of the XC functional ixc',ch10,&
&       '  is not compatible with the value of nvxcgrho or ngr2',ch10,&
&       '  ixc=',ixc,'  nvxcgrho=',nvxcgrho,'  ngr2=',ngr2
       call wrtout(std_out,message,'COLL')
       call leave_new('COLL')
     end if
   end if

   if (libxc_functionals_ismgga()) then
     if ( (.not. present(lrho_updn)) .or. (.not. present(vxclrho)) .or. &
     (.not. present(tau_updn))  .or. (.not. present(vxctau))          )  then
       write(message, '(8a,i7)' )ch10,&
&       ' drivexc : ERROR -',ch10,&
&       '  At least one of the functionals is a MGGA,',ch10,&
&       '  but not all the necessary arrays are present.',ch10,&
&       '  ixc=',ixc
       call wrtout(std_out,message,'COLL')
       call leave_new('COLL')
     end if
   end if

!  DEBUG
!  write(std_out,*)' drivexc : before libxc_functionals_getvxc'
!  write(std_out,*)' npts=',npts
!  write(std_out,*)' nspden=',nspden
!  write(std_out,*)' rho_updn(1:3,1)=',rho_updn(1:3,1)
!  write(std_out,*)' grho2_updn(1:3,1)=',grho2_updn(1:3,1)
!  write(std_out,*)' lrho_updn(1:3,1)=',lrho_updn(1:3,1)
!  write(std_out,*)' tau_updn(1:3,1)=',tau_updn(1:3,1)
!  grho2_updn(1,1)=zero
!  write(std_out,*)' set grho2_updn(1,1) to zero '
!  ENDDEBUG


!  Call LibXC routines
   if (libxc_functionals_ismgga()) then

     call libxc_functionals_getvxc(ndvxc,nd2vxc,npts,nspden,order,rho_updn,exc,&
&     vxcrho,grho2_updn,vxcgrho,lrho_updn,vxclrho,tau_updn,vxctau)

     ixc1 = (-ixc)/1000
     ixc2 = (-ixc) - ixc1*1000
     if(ixc1==206 .or. ixc1==207 .or. ixc1==208 .or. ixc1==209 .or. &
&     ixc2==206 .or. ixc2==207 .or. ixc2==208 .or. ixc2==209    )then
!      Assume that that type of mGGA can only be used with a LDA correlation (see doc)
       vxcgrho(:,:)=zero
       vxclrho(:,:)=zero
       vxctau(:,:)=zero
     end if
!    if(ixc==-12206 .or. ixc==-12207 .or. ixc==-12208 .or. ixc==-12209)then
!    vxcgrho(:,:)=zero
!    vxclrho(:,:)=zero
!    vxctau(:,:)=zero
!    end if

   elseif (libxc_functionals_isgga()) then
     if (order**2 <= 1) then
       call libxc_functionals_getvxc(ndvxc,nd2vxc,npts,nspden,order,rho_updn,exc,&
&       vxcrho,grho2=grho2_updn,vxcgr=vxcgrho)
     else
       call libxc_functionals_getvxc(ndvxc,nd2vxc,npts,nspden,order,rho_updn,exc,&
&       vxcrho,grho2=grho2_updn,vxcgr=vxcgrho,lrho=lrho_updn,vxclrho=vxclrho,&
&       tau=tau_updn,vxctau=vxctau,dvxc=dvxc)
     end if
   else
     if (order**2 <= 1) then
       call libxc_functionals_getvxc(ndvxc,nd2vxc,npts,nspden,order,rho_updn,exc,&
&       vxcrho)
     elseif (order**2 <= 4) then
       call libxc_functionals_getvxc(ndvxc,nd2vxc,npts,nspden,order,rho_updn,exc,&
&       vxcrho,dvxc=dvxc)
     else
       call libxc_functionals_getvxc(ndvxc,nd2vxc,npts,nspden,order,rho_updn,exc,&
&       vxcrho,dvxc=dvxc,d2vxc=d2vxc)
     end if
   end if

!  DEBUG
!  write(std_out,*)' rho_updn(1:3,1)=',rho_updn(1:3,1)
!  write(std_out,*)' grho2_updn(1:3,1)=',grho2_updn(1:3,1)
!  write(std_out,*)' lrho_updn(1:3,1)=',lrho_updn(1:3,1)
!  write(std_out,*)' tau_updn(1:3,1)=',tau_updn(1:3,1)
!  write(std_out,*)' exc(1:3)=',exc(1:3)
!  write(std_out,*)' vxcrho(1:3,1)=',vxcrho(1:3,1)
!  write(std_out,*)' vxcgrho(1:3,1)=',vxcgrho(1:3,1)
!  write(std_out,*)' vxclrho(1:3,1)=',vxclrho(1:3,1)
!  write(std_out,*)' vxctau(1:3,1)=',vxctau(1:3,1)
!  write(std_out,*)' ixc=',ixc
!  stop
!  ENDDEBUG


#else
   write(message, '(5a)' )ch10,&
&   ' drivexc : ERROR -',ch10,&
&   '  ABINIT was not compiled with LibXC support',ch10
   call wrtout(std_out,message,'COLL')
   call leave_new('COLL')
#endif
 end if

!!! !Pass the output to the optional arrays
!!! if(abs(order)>1)then
!!!  if(present(dvxc))then
!!!   dvxc(:,:)=dvxci(:,1:size(dvxc,2))
!!!  end if
!!! end if
!!$
!!! if(abs(order)>2)then
!!!  if(present(d2vxc))then
!!!   d2vxc(:)=d2vxci(:)
!!!  end if
!!! end if

!Deallocate arrays
 if(allocated(rhotot))ABI_DEALLOCATE(rhotot)
 if(allocated(rspts))ABI_DEALLOCATE(rspts)
 if(allocated(zeta))ABI_DEALLOCATE(zeta)

!DEBUG
!sum=0.0
!do kk=1,npts
!sum=sum+abs(exc(kk))
!end do
!write(std_out,*) 'SUM(exc)',sum
!sum=0.0
!do jj=1,nspden
!do kk=1,npts
!sum=sum+abs(vxcrho(kk,jj))
!end do
!end do
!write(std_out,*) 'SUM(vxc)',sum
!write(std_out,*)'-> drivexc : exit'
!write(std_out,*)'-----------------'
!ENDDEBUG

end subroutine drivexc
!!***
