/*--
 LocalExec.java - Created in July 2009

 Copyright (c) 2009-2011 Flavio Miguel ABREU ARAUJO.
 Université catholique de Louvain, Louvain-la-Neuve, Belgium
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions, and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions, and the disclaimer that follows
    these conditions in the documentation and/or other materials
    provided with the distribution.

 3. The names of the author may not be used to endorse or promote
    products derived from this software without specific prior written
    permission.

 In addition, we request (but do not require) that you include in the
 end-user documentation provided with the redistribution and/or in the
 software itself an acknowledgement equivalent to the following:
     "This product includes software developed by the
      Abinit Project (http://www.abinit.org/)."

 THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED.  IN NO EVENT SHALL THE JDOM AUTHORS OR THE PROJECT
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 SUCH DAMAGE.

 For more information on the Abinit Project, please see
 <http://www.abinit.org/>.
 */

package abinitgui;

import java.io.*;

public class LocalExec {

    private Runtime rt;
    private Process proc;
    private LocalExecOutput leErr;
    private LocalExecOutput leOut;
    private String succesMSG = null;
    private String errorMSG = null;
    final private int ERROR_TYPE = 1;
    final private int SUCCES_TYPE = 0;

    private DisplayerJDialog dialog;
    private boolean graphical = false;

    public void setDialog(DisplayerJDialog dialog) {
        graphical = true;
        this.dialog = dialog;
    }

    void printOUT(String str) {
        if (graphical) {
            if (str.endsWith("\n")) {
                dialog.appendOUT(str);
            } else {
                dialog.appendOUT(str + "\n");
            }
        } else {
            if (str.endsWith("\n")) {
                System.out.print(str);
            } else {
                System.out.println(str);
            }
        }
    }

    void printERR(String str) {
        if (graphical) {
            if (str.endsWith("\n")) {
                dialog.appendERR(str);
            } else {
                dialog.appendERR(str + "\n");
            }
        } else {
            if (str.endsWith("\n")) {
                System.err.print(str);
            } else {
                System.err.println(str);
            }
        }
    }

    void printDEB(String str) {
        if (graphical) {
            if (str.endsWith("\n")) {
                dialog.appendDEB(str);
            } else {
                dialog.appendDEB(str + "\n");
            }
        } else {
            if (str.endsWith("\n")) {
                System.out.print(str);
            } else {
                System.out.println(str);
            }
        }
    }

    public LocalExec() {
        rt = Runtime.getRuntime();
    }

    public RetMSG sendCommand(String CMD) {
        try {
            proc = rt.exec(CMD);
        } catch (Exception e) {
            errorMSG += e;
            return new RetMSG(-1, errorMSG, CMD);
        }
        try {
            leErr = new LocalExecOutput(proc.getErrorStream(), ERROR_TYPE);
            leOut = new LocalExecOutput(proc.getInputStream(), SUCCES_TYPE);
            int exitVal = proc.waitFor();
            if (exitVal == RetMSG.SUCCES) {
                leOut.join();
                return new RetMSG(RetMSG.SUCCES, succesMSG, CMD);
            } else {
                leErr.join();
                return new RetMSG(exitVal, errorMSG, CMD);
            }
        } catch (Exception e) {
            errorMSG += e;
            return new RetMSG(-1, errorMSG, CMD);
        }
    }

    public class LocalExecOutput extends Thread {

        private InputStream input;
        private int streamType;

        public LocalExecOutput(InputStream input, int streamType) {
            this.input = input;
            this.streamType = streamType;
            this.start();
        }

        @Override
        public void run() {
            if (streamType == ERROR_TYPE) {
                errorMSG = "";
            } else {
                succesMSG = "";
            }
            byte[] buf = new byte[1024];
            int i = 0;
            try {
                while (true) {
                    i = input.read(buf, 0, 1024);
                    if (i <= 0) {
                        break;
                    } else {
                        byte[] tmp = new byte[i];
                        /*for (int k = 0; k < i; k++) {
                            tmp[k] = buf[k];
                        }*/
                        System.arraycopy(buf, 0, tmp, 0, i);
                        
                        if (streamType == ERROR_TYPE) {
                            errorMSG += new String(tmp);
                        } else {
                            succesMSG += new String(tmp);
                        }
                    }
                    if (!(input.available() > 0)) {
                        break;
                    }
                }
            } catch (Exception e) {
                printERR(e.getMessage());
            }
        }
    }
}
