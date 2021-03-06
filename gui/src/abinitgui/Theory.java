/*--
 Theory.java - Created March 27, 2010

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

import java.awt.Color;
import javax.swing.JTable;
import javax.swing.table.DefaultTableColumnModel;
import javax.swing.table.TableColumn;
import javax.swing.table.TableColumnModel;

/**
 *
 * @author flavio
 */
//@SuppressWarnings("serial")
public class Theory extends javax.swing.JPanel {

    private DisplayerJDialog outDialog;
    private MyTableModel upawuModel = null;
    private MyTableModel lpawuModel = null;
    private MyTableModel jpawuModel = null;
    private MainFrame mainFrame;

    /** Creates new form Theory */
    public Theory(DisplayerJDialog outD, MainFrame parent) {
        outDialog = outD;
        mainFrame = parent;
        initComponents();

        upawuModel = new MyTableModel(upawuTable);
        upawuTable.setModel(upawuModel);
        initTableHeader(upawuTable, new String[]{"Scr.Coul.Int."},
                new Integer[]{null});
        upawuTable.setVisible(false);

        lpawuModel = new MyTableModel(lpawuTable);
        lpawuTable.setModel(lpawuModel);
        initTableHeader(lpawuTable, new String[]{"Ang.Mom."},
                new Integer[]{null});
        lpawuTable.setVisible(false);

        jpawuModel = new MyTableModel(jpawuTable);
        jpawuTable.setModel(jpawuModel);
        initTableHeader(jpawuTable, new String[]{"J Val."},
                new Integer[]{null});
        jpawuTable.setVisible(false);
    }

    private void initTableHeader(JTable table, String header[], Integer headerWidths[]) {
        TableColumnModel tcm = new DefaultTableColumnModel();
        for (int i = 0; i < header.length; i++) {
            TableColumn tc = new TableColumn(i);
            tc.setHeaderValue(header[i]);
            tc.setResizable(false);
            if (headerWidths[i] != null) {
                tc.setMinWidth(headerWidths[i]);
                tc.setPreferredWidth(headerWidths[i]);
                tc.setMaxWidth(headerWidths[i]);
            }
            tcm.addColumn(tc);
        }
        table.setColumnModel(tcm);
    }

    public void printERR(String s) {
        // TODO mettre de la couleur
        if (s.endsWith("\n")) {
            outDialog.appendERR(s);
        } else {
            outDialog.appendERR(s + "\n");
        }
    }

    public void printOUT(String s) {
        if (s.endsWith("\n")) {
            outDialog.appendOUT(s);
        } else {
            outDialog.appendOUT(s + "\n");
        }
    }

    String removeEndl(String str) {
        if (str.endsWith("\n")) {
            return (String) str.subSequence(0, str.lastIndexOf('\n'));
        } else {
            return str;
        }
    }

    private void printDEB(String str) {
        if (str.endsWith("\n")) {
            outDialog.appendDEB("DEBUG: " + str);
        } else {
            outDialog.appendDEB("DEBUG: " + str + "\n");
        }
    }

    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    //@SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        ixcCheckBox = new javax.swing.JCheckBox();
        ixcComboBox = new javax.swing.JComboBox();
        optdriverComboBox = new javax.swing.JComboBox();
        optdriverCheckBox = new javax.swing.JCheckBox();
        usepawuCheckBox = new javax.swing.JCheckBox();
        usepawuComboBox = new javax.swing.JComboBox();
        jScrollPane1 = new javax.swing.JScrollPane();
        upawuTable = new javax.swing.JTable();
        upawuCheckBox = new javax.swing.JCheckBox();
        jScrollPane2 = new javax.swing.JScrollPane();
        lpawuTable = new javax.swing.JTable();
        lpawuCheckBox = new javax.swing.JCheckBox();
        jpawuCheckBox = new javax.swing.JCheckBox();
        jScrollPane3 = new javax.swing.JScrollPane();
        jpawuTable = new javax.swing.JTable();

        ixcCheckBox.setForeground(java.awt.Color.blue);
        ixcCheckBox.setText("ixc");
        ixcCheckBox.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                ixcCheckBoxActionPerformed(evt);
            }
        });

        ixcComboBox.setModel(new javax.swing.DefaultComboBoxModel(new String[] { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "26", "27", "28" }));
        ixcComboBox.setSelectedIndex(1);
        ixcComboBox.setEnabled(false);

        optdriverComboBox.setModel(new javax.swing.DefaultComboBoxModel(new String[] { "0", "1", "2", "3", "4", "5" }));
        optdriverComboBox.setEnabled(false);

        optdriverCheckBox.setForeground(java.awt.Color.blue);
        optdriverCheckBox.setText("optdriver");
        optdriverCheckBox.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                optdriverCheckBoxActionPerformed(evt);
            }
        });

        usepawuCheckBox.setForeground(java.awt.Color.blue);
        usepawuCheckBox.setText("usepawu");
        usepawuCheckBox.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                usepawuCheckBoxActionPerformed(evt);
            }
        });

        usepawuComboBox.setModel(new javax.swing.DefaultComboBoxModel(new String[] { "0", "1", "2" }));
        usepawuComboBox.setEnabled(false);

        upawuTable.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {

            },
            new String [] {

            }
        ));
        upawuTable.getTableHeader().setReorderingAllowed(false);
        jScrollPane1.setViewportView(upawuTable);

        upawuCheckBox.setForeground(java.awt.Color.blue);
        upawuCheckBox.setText("upawu");
        upawuCheckBox.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                upawuCheckBoxActionPerformed(evt);
            }
        });

        lpawuTable.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {

            },
            new String [] {

            }
        ));
        lpawuTable.getTableHeader().setReorderingAllowed(false);
        jScrollPane2.setViewportView(lpawuTable);

        lpawuCheckBox.setForeground(java.awt.Color.blue);
        lpawuCheckBox.setText("lpawu");
        lpawuCheckBox.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                lpawuCheckBoxActionPerformed(evt);
            }
        });

        jpawuCheckBox.setForeground(java.awt.Color.blue);
        jpawuCheckBox.setText("jpawu");
        jpawuCheckBox.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jpawuCheckBoxActionPerformed(evt);
            }
        });

        jpawuTable.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {

            },
            new String [] {

            }
        ));
        jpawuTable.getTableHeader().setReorderingAllowed(false);
        jScrollPane3.setViewportView(jpawuTable);

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(this);
        this.setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(layout.createSequentialGroup()
                        .addComponent(optdriverCheckBox)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(optdriverComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ixcCheckBox)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(ixcComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(usepawuCheckBox)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(usepawuComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(layout.createSequentialGroup()
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(jScrollPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 92, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(upawuCheckBox))
                        .addGap(18, 18, 18)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(lpawuCheckBox)
                            .addComponent(jScrollPane2, javax.swing.GroupLayout.PREFERRED_SIZE, 92, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addGap(18, 18, 18)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(jpawuCheckBox)
                            .addComponent(jScrollPane3, javax.swing.GroupLayout.PREFERRED_SIZE, 92, javax.swing.GroupLayout.PREFERRED_SIZE))))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(optdriverCheckBox)
                    .addComponent(optdriverComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(ixcCheckBox)
                    .addComponent(ixcComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(usepawuCheckBox)
                    .addComponent(usepawuComboBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(18, 18, 18)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                    .addGroup(layout.createSequentialGroup()
                        .addComponent(upawuCheckBox)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(jScrollPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 103, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(layout.createSequentialGroup()
                        .addComponent(lpawuCheckBox)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(jScrollPane2, javax.swing.GroupLayout.PREFERRED_SIZE, 103, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(layout.createSequentialGroup()
                        .addComponent(jpawuCheckBox)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(jScrollPane3, javax.swing.GroupLayout.PREFERRED_SIZE, 103, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
    }// </editor-fold>//GEN-END:initComponents

    private void ixcCheckBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_ixcCheckBoxActionPerformed
        if (ixcCheckBox.isSelected()) {
            ixcCheckBox.setForeground(Color.red);
            ixcComboBox.setEnabled(true);
        } else {
            ixcCheckBox.setForeground(Color.blue);
            ixcComboBox.setEnabled(false);
        }
}//GEN-LAST:event_ixcCheckBoxActionPerformed

    private void optdriverCheckBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_optdriverCheckBoxActionPerformed
        if (optdriverCheckBox.isSelected()) {
            optdriverCheckBox.setForeground(Color.red);
            optdriverComboBox.setEnabled(true);
        } else {
            optdriverCheckBox.setForeground(Color.blue);
            optdriverComboBox.setEnabled(false);
        }
    }//GEN-LAST:event_optdriverCheckBoxActionPerformed

    private void usepawuCheckBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_usepawuCheckBoxActionPerformed
        if (usepawuCheckBox.isSelected()) {
            usepawuCheckBox.setForeground(Color.red);
            usepawuComboBox.setEnabled(true);
        } else {
            usepawuCheckBox.setForeground(Color.blue);
            usepawuComboBox.setEnabled(false);
        }
    }//GEN-LAST:event_usepawuCheckBoxActionPerformed

    private void upawuCheckBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_upawuCheckBoxActionPerformed
        if (upawuCheckBox.isSelected()) {
            upawuCheckBox.setForeground(Color.red);
            upawuTable.setEnabled(true);
            upawuTable.setVisible(true);
            try {
                int ntypat = Integer.parseInt(mainFrame.getNtypat());
                if(ntypat == 0) {
                    printERR("Please setup NTYPAT !");
                }

                if (ntypat > 1000) {
                    ntypat = 1000;
                    Object strTab[][] = new Object[ntypat][1];
                    for (int i = 0; i < ntypat; i++) {
                        strTab[i] = new Object[]{new Double(0.0)};
                    }
                    upawuModel.setData(strTab);
                } else {
                    Object strTab[][] = new Object[ntypat][1];
                    for (int i = 0; i < ntypat; i++) {
                        strTab[i] = new Object[]{new Double(0.0)};
                    }
                    upawuModel.setData(strTab);
                }
            } catch (Exception e) {
                //printERR(e.getMessage());
                printERR("Please setup NTYPAT !");
                upawuModel.setData(null);
            }
        } else {
            upawuCheckBox.setForeground(Color.blue);
            upawuTable.setEnabled(false);
            upawuTable.setVisible(false);
        }
    }//GEN-LAST:event_upawuCheckBoxActionPerformed

    private void lpawuCheckBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_lpawuCheckBoxActionPerformed
        if (lpawuCheckBox.isSelected()) {
            lpawuCheckBox.setForeground(Color.red);
            lpawuTable.setEnabled(true);
            lpawuTable.setVisible(true);
            try {
                int ntypat = Integer.parseInt(mainFrame.getNtypat());
                if(ntypat == 0) {
                    printERR("Please setup NTYPAT !");
                }

                if (ntypat > 1000) {
                    ntypat = 1000;
                    Object strTab[][] = new Object[ntypat][1];
                    for (int i = 0; i < ntypat; i++) {
                        strTab[i] = new Object[]{new Integer(0)};
                    }
                    lpawuModel.setData(strTab);
                } else {
                    Object strTab[][] = new Object[ntypat][1];
                    for (int i = 0; i < ntypat; i++) {
                        strTab[i] = new Object[]{new Integer(0)};
                    }
                    lpawuModel.setData(strTab);
                }
            } catch (Exception e) {
                //printERR(e.getMessage());
                printERR("Please setup NTYPAT !");
                lpawuModel.setData(null);
            }
        } else {
            lpawuCheckBox.setForeground(Color.blue);
            lpawuTable.setEnabled(false);
            lpawuTable.setVisible(false);
        }
    }//GEN-LAST:event_lpawuCheckBoxActionPerformed

    private void jpawuCheckBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jpawuCheckBoxActionPerformed
        if (jpawuCheckBox.isSelected()) {
            jpawuCheckBox.setForeground(Color.red);
            jpawuTable.setEnabled(true);
            jpawuTable.setVisible(true);
            try {
                int ntypat = Integer.parseInt(mainFrame.getNtypat());
                if(ntypat == 0) {
                    printERR("Please setup NTYPAT !");
                }

                if (ntypat > 1000) {
                    ntypat = 1000;
                    Object strTab[][] = new Object[ntypat][1];
                    for (int i = 0; i < ntypat; i++) {
                        strTab[i] = new Object[]{new Double(0.0)};
                    }
                    jpawuModel.setData(strTab);
                } else {
                    Object strTab[][] = new Object[ntypat][1];
                    for (int i = 0; i < ntypat; i++) {
                        strTab[i] = new Object[]{new Double(0.0)};
                    }
                    jpawuModel.setData(strTab);
                }
            } catch (Exception e) {
                //printERR(e.getMessage());
                printERR("Please setup NTYPAT !");
                jpawuModel.setData(null);
            }
        } else {
            jpawuCheckBox.setForeground(Color.blue);
            jpawuTable.setEnabled(false);
            jpawuTable.setVisible(false);
        }
    }//GEN-LAST:event_jpawuCheckBoxActionPerformed

    public String getData() {
        String file = new String();

        // OPTDRIVER ***********************************************************
        if (optdriverCheckBox.isSelected()) {
            file += optdriverCheckBox.getText() + " ";
            file += optdriverComboBox.getSelectedItem() + "\n\n";
        }
        // IXC *****************************************************************
        if (ixcCheckBox.isSelected()) {
            file += ixcCheckBox.getText() + " ";
            file += ixcComboBox.getSelectedItem() + "\n\n";
        }
        // USEPAWU *************************************************************
        if (usepawuCheckBox.isSelected()) {
            file += usepawuCheckBox.getText() + " ";
            file += usepawuComboBox.getSelectedItem() + "\n\n";
        }
        // UPAWU *****************************************************************
        if (upawuCheckBox.isSelected()) {
            int col = upawuTable.getColumnCount();
            int row = upawuTable.getRowCount();
            if (row > 0) {
                file += upawuCheckBox.getText();
                for (int i = 0; i < row; i++) {
                    for (int j = 0; j < col; j++) {
                        try {
                            file += " " + upawuTable.getValueAt(i, j);
                        } catch (Exception e) {
                            printERR("Please set up UPAWU !");
                        }
                    }
                }
                file += "\n\n";
            }
        }
        // LPAWU *****************************************************************
        if (lpawuCheckBox.isSelected()) {
            int col = lpawuTable.getColumnCount();
            int row = lpawuTable.getRowCount();
            if (row > 0) {
                file += lpawuCheckBox.getText();
                for (int i = 0; i < row; i++) {
                    for (int j = 0; j < col; j++) {
                        try {
                            file += " " + lpawuTable.getValueAt(i, j);
                        } catch (Exception e) {
                            printERR("Please set up LPAWU !");
                        }
                    }
                }
                file += "\n\n";
            }
        }
        // JPAWU *****************************************************************
        if (jpawuCheckBox.isSelected()) {
            int col = jpawuTable.getColumnCount();
            int row = jpawuTable.getRowCount();
            if (row > 0) {
                file += jpawuCheckBox.getText();
                for (int i = 0; i < row; i++) {
                    for (int j = 0; j < col; j++) {
                        try {
                            file += " " + jpawuTable.getValueAt(i, j);
                        } catch (Exception e) {
                            printERR("Please set up JPAWU !");
                        }
                    }
                }
                file += "\n\n";
            }
        }

        return file;
    }
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JCheckBox ixcCheckBox;
    private javax.swing.JComboBox ixcComboBox;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JScrollPane jScrollPane2;
    private javax.swing.JScrollPane jScrollPane3;
    private javax.swing.JCheckBox jpawuCheckBox;
    private javax.swing.JTable jpawuTable;
    private javax.swing.JCheckBox lpawuCheckBox;
    private javax.swing.JTable lpawuTable;
    private javax.swing.JCheckBox optdriverCheckBox;
    private javax.swing.JComboBox optdriverComboBox;
    private javax.swing.JCheckBox upawuCheckBox;
    private javax.swing.JTable upawuTable;
    private javax.swing.JCheckBox usepawuCheckBox;
    private javax.swing.JComboBox usepawuComboBox;
    // End of variables declaration//GEN-END:variables
}
