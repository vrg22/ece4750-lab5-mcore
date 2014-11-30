//========================================================================
// ubmark-vvadd: vector-vector addition kernel
//========================================================================
//
// This code does adds the values of two arrays and stores the result to
// the destination array. The code is equivalent to:
//
// void vvadd( int *dest, int *src0, int *src1, int size ) {
//   for ( int i = 0; i < size; i++ )
//     *dest++ = *src0++ + *src1++;
// }

// pointers for the input and output arrays
localparam c_vvadd_src0_ptr = 32'h2000;
localparam c_vvadd_src1_ptr = 32'h3000;
localparam c_vvadd_dest_ptr = 32'h4000;
localparam c_vvadd_size     = 100;

//------------------------------------------------------------------------
// initialize unoptimized (not unrolled) vector vector add kernel
//------------------------------------------------------------------------

task init_vvadd_unopt;
begin
  clear_mem;

  address( c_reset_vector );
  // load pointers and array size
  inst( "mfc0  r1, mngr2proc " ); init_src( c_vvadd_size );
  inst( "mfc0  r2, mngr2proc " ); init_src( c_vvadd_src0_ptr );
  inst( "mfc0  r3, mngr2proc " ); init_src( c_vvadd_src1_ptr );
  inst( "mfc0  r4, mngr2proc " ); init_src( c_vvadd_dest_ptr );
  inst( "addiu r5, r0, 0     " );
  // loop:
  inst( "lw    r6, 0(r2)     " );
  inst( "lw    r7, 0(r3)     " );
  inst( "addu  r8, r6, r7    " );
  inst( "sw    r8, 0(r4)     " );
  inst( "addiu r2, r2, 4     " );
  inst( "addiu r3, r3, 4     " );
  inst( "addiu r4, r4, 4     " );
  inst( "addiu r5, r5, 1     " );
  inst( "bne   r5, r1, [-8]  " ); // goto loop:
  // after loop:, marks the end of program
  inst( "mtc0  r0, proc2mngr " ); init_sink( 32'h00000000 );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );

  // initialize data
  init_vvadd_data;

end
endtask

//------------------------------------------------------------------------
// initialize optimized (unrolled) vector vector add kernel
//------------------------------------------------------------------------

task init_vvadd_opt;
begin
  clear_mem;

  address( c_reset_vector );
  // load pointers and array size
  inst( "mfc0  r1, mngr2proc " ); init_src( c_vvadd_size  );
  inst( "mfc0  r2, mngr2proc " ); init_src( c_vvadd_src0_ptr );
  inst( "mfc0  r3, mngr2proc " ); init_src( c_vvadd_src1_ptr );
  inst( "mfc0  r4, mngr2proc " ); init_src( c_vvadd_dest_ptr );
  inst( "addiu r5, r0, 0     " );
  // loop:
  inst( "lw    r6,   0(r2)   " );
  inst( "lw    r7,   4(r2)   " );
  inst( "lw    r8,   8(r2)   " );
  inst( "lw    r9,  12(r2)   " );
  inst( "lw    r10,  0(r3)   " );
  inst( "lw    r11,  4(r3)   " );
  inst( "lw    r12,  8(r3)   " );
  inst( "lw    r13, 12(r3)   " );
  inst( "addu  r6, r6, r10   " );
  inst( "addu  r7, r7, r11   " );
  inst( "addu  r8, r8, r12   " );
  inst( "addu  r9, r9, r13   " );
  inst( "sw    r6,   0(r4)   " );
  inst( "sw    r7,   4(r4)   " );
  inst( "sw    r8,   8(r4)   " );
  inst( "sw    r9,  12(r4)   " );
  inst( "addiu r5, r5, 4     " );
  inst( "addiu r2, r2, 16    " );
  inst( "addiu r3, r3, 16    " );
  inst( "addiu r4, r4, 16    " );
  inst( "bne   r5, r1, [-20] " ); // goto loop:
  // after loop:, marks the end of program
  inst( "mtc0  r0, proc2mngr " ); init_sink( 32'h00000000 );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );

  // initialize data
  init_vvadd_data;

end
endtask

//------------------------------------------------------------------------
// initialize source and reference data for vvadd
//------------------------------------------------------------------------

task init_vvadd_data;
begin

  ubmark_name = "vvadd";
  ubmark_dest_size = c_vvadd_size;

  address( c_vvadd_src0_ptr );

  data( 32'd16807       );
  data( 32'd1622650073  );
  data( 32'd1144108930  );
  data( 32'd101027544   );
  data( 32'd1458777923  );
  data( 32'd823564440   );
  data( 32'd1784484492  );
  data( 32'd114807987   );
  data( 32'd1441282327  );
  data( 32'd823378840   );
  data( 32'd896544303   );
  data( 32'd1264817709  );
  data( 32'd1817129560  );
  data( 32'd197493099   );
  data( 32'd893351816   );
  data( 32'd1954899097  );
  data( 32'd563613512   );
  data( 32'd1580723810  );
  data( 32'd1358580979  );
  data( 32'd2128236579  );
  data( 32'd530511967   );
  data( 32'd1551901393  );
  data( 32'd1399125485  );
  data( 32'd1356425228  );
  data( 32'd585640194   );
  data( 32'd1646035001  );
  data( 32'd510616708   );
  data( 32'd771515668   );
  data( 32'd1044788124  );
  data( 32'd1952509530  );
  data( 32'd1942727722  );
  data( 32'd1108728549  );
  data( 32'd2118797801  );
  data( 32'd571540977   );
  data( 32'd2035308228  );
  data( 32'd1075260298  );
  data( 32'd595028635   );
  data( 32'd1137623865  );
  data( 32'd2020739063  );
  data( 32'd1635339425  );
  data( 32'd1777724115  );
  data( 32'd34075629    );
  data( 32'd1864546517  );
  data( 32'd1581030105  );
  data( 32'd2146319451  );
  data( 32'd500782188   );
  data( 32'd753799505   );
  data( 32'd1269406752  );
  data( 32'd884936716   );
  data( 32'd578354438   );
  data( 32'd1153851501  );
  data( 32'd616783871   );
  data( 32'd330111137   );
  data( 32'd1723153177  );
  data( 32'd1147722294  );
  data( 32'd2051621609  );
  data( 32'd1190959745  );
  data( 32'd1341853635  );
  data( 32'd343098142   );
  data( 32'd1534827968  );
  data( 32'd195400260   );
  data( 32'd6441594     );
  data( 32'd57716395    );
  data( 32'd2014119113  );
  data( 32'd388471006   );
  data( 32'd1904797942  );
  data( 32'd322842082   );
  data( 32'd828530767   );
  data( 32'd1073185695  );
  data( 32'd1260973671  );
  data( 32'd1267248590  );
  data( 32'd1194314738  );
  data( 32'd2111631616  );
  data( 32'd304555640   );
  data( 32'd541437335   );
  data( 32'd996497972   );
  data( 32'd270649095   );
  data( 32'd685583454   );
  data( 32'd272112289   );
  data( 32'd1334948905  );
  data( 32'd532236123   );
  data( 32'd836045813   );
  data( 32'd60935238    );
  data( 32'd915896220   );
  data( 32'd2034712366  );
  data( 32'd281725226   );
  data( 32'd197941363   );
  data( 32'd152607844   );
  data( 32'd543436550   );
  data( 32'd1681808623  );
  data( 32'd750597385   );
  data( 32'd1737195272  );
  data( 32'd1399399247  );
  data( 32'd1459413496  );
  data( 32'd537140623   );
  data( 32'd1012028144  );
  data( 32'd1289335735  );
  data( 32'd1623161625  );
  data( 32'd2043046042  );
  data( 32'd943454679   );


  address( c_vvadd_src1_ptr );

  data( 32'd282475249   );
  data( 32'd984943658   );
  data( 32'd470211272   );
  data( 32'd1457850878  );
  data( 32'd2007237709  );
  data( 32'd1115438165  );
  data( 32'd74243042    );
  data( 32'd1137522503  );
  data( 32'd16531729    );
  data( 32'd143542612   );
  data( 32'd1474833169  );
  data( 32'd1998097157  );
  data( 32'd1131570933  );
  data( 32'd1404280278  );
  data( 32'd1505795335  );
  data( 32'd1636807826  );
  data( 32'd101929267   );
  data( 32'd704877633   );
  data( 32'd1624379149  );
  data( 32'd784558821   );
  data( 32'd2110010672  );
  data( 32'd1617819336  );
  data( 32'd156091745   );
  data( 32'd1899894091  );
  data( 32'd937186357   );
  data( 32'd1025921153  );
  data( 32'd590357944   );
  data( 32'd357571490   );
  data( 32'd1927702196  );
  data( 32'd130060903   );
  data( 32'd1083454666  );
  data( 32'd685118024   );
  data( 32'd1060806853  );
  data( 32'd194847408   );
  data( 32'd158374933   );
  data( 32'd824938981   );
  data( 32'd1962408013  );
  data( 32'd997389814   );
  data( 32'd107554536   );
  data( 32'd1654001669  );
  data( 32'd269220094   );
  data( 32'd1478446501  );
  data( 32'd1351934195  );
  data( 32'd1557810404  );
  data( 32'd1908194298  );
  data( 32'd657821123   );
  data( 32'd1102246882  );
  data( 32'd1816731566  );
  data( 32'd1807130337  );
  data( 32'd892053144   );
  data( 32'd1004844897  );
  data( 32'd382955828   );
  data( 32'd1227619358  );
  data( 32'd70982397    );
  data( 32'd1070477904  );
  data( 32'd1606946231  );
  data( 32'd1912844175  );
  data( 32'd1808266298  );
  data( 32'd456880399   );
  data( 32'd280090412   );
  data( 32'd589673557   );
  data( 32'd889688008   );
  data( 32'd1524325968  );
  data( 32'd515204530   );
  data( 32'd681910962   );
  data( 32'd1400285365  );
  data( 32'd1463179852  );
  data( 32'd832633821   );
  data( 32'd316824712   );
  data( 32'd1815859901  );
  data( 32'd2051724831  );
  data( 32'd318153057   );
  data( 32'd877819790   );
  data( 32'd1213110679  );
  data( 32'd1049077006  );
  data( 32'd2063936098  );
  data( 32'd428975319   );
  data( 32'd1351345223  );
  data( 32'd1398556760  );
  data( 32'd1724586126  );
  data( 32'd1023129506  );
  data( 32'd436476770   );
  data( 32'd1936329094  );
  data( 32'd304987844   );
  data( 32'd881140534   );
  data( 32'd1901915394  );
  data( 32'd348318738   );
  data( 32'd784559590   );
  data( 32'd290145159   );
  data( 32'd977764947   );
  data( 32'd971307217   );
  data( 32'd2000755539  );
  data( 32'd462242385   );
  data( 32'd1951894885  );
  data( 32'd1848682420  );
  data( 32'd1086531968  );
  data( 32'd1755699915  );
  data( 32'd992663534   );
  data( 32'd1358796011  );
  data( 32'd1771024152  );

  ref_address( c_vvadd_dest_ptr );

  ref_data( 32'd282492056  );
  ref_data(-32'd1687373565 );
  ref_data( 32'd1614320202 );
  ref_data( 32'd1558878422 );
  ref_data(-32'd828951664  );
  ref_data( 32'd1939002605 );
  ref_data( 32'd1858727534 );
  ref_data( 32'd1252330490 );
  ref_data( 32'd1457814056 );
  ref_data( 32'd966921452  );
  ref_data(-32'd1923589824 );
  ref_data(-32'd1032052430 );
  ref_data(-32'd1346266803 );
  ref_data( 32'd1601773377 );
  ref_data(-32'd1895820145 );
  ref_data(-32'd703260373  );
  ref_data( 32'd665542779  );
  ref_data(-32'd2009365853 );
  ref_data(-32'd1312007168 );
  ref_data(-32'd1382171896 );
  ref_data(-32'd1654444657 );
  ref_data(-32'd1125246567 );
  ref_data( 32'd1555217230 );
  ref_data(-32'd1038647977 );
  ref_data( 32'd1522826551 );
  ref_data(-32'd1623011142 );
  ref_data( 32'd1100974652 );
  ref_data( 32'd1129087158 );
  ref_data(-32'd1322476976 );
  ref_data( 32'd2082570433 );
  ref_data(-32'd1268784908 );
  ref_data( 32'd1793846573 );
  ref_data(-32'd1115362642 );
  ref_data( 32'd766388385  );
  ref_data(-32'd2101284135 );
  ref_data( 32'd1900199279 );
  ref_data(-32'd1737530648 );
  ref_data( 32'd2135013679 );
  ref_data( 32'd2128293599 );
  ref_data(-32'd1005626202 );
  ref_data( 32'd2046944209 );
  ref_data( 32'd1512522130 );
  ref_data(-32'd1078486584 );
  ref_data(-32'd1156126787 );
  ref_data(-32'd240453547  );
  ref_data( 32'd1158603311 );
  ref_data( 32'd1856046387 );
  ref_data(-32'd1208828978 );
  ref_data(-32'd1602900243 );
  ref_data( 32'd1470407582 );
  ref_data(-32'd2136270898 );
  ref_data( 32'd999739699  );
  ref_data( 32'd1557730495 );
  ref_data( 32'd1794135574 );
  ref_data(-32'd2076767098 );
  ref_data(-32'd636399456  );
  ref_data(-32'd1191163376 );
  ref_data(-32'd1144847363 );
  ref_data( 32'd799978541  );
  ref_data( 32'd1814918380 );
  ref_data( 32'd785073817  );
  ref_data( 32'd896129602  );
  ref_data( 32'd1582042363 );
  ref_data(-32'd1765643653 );
  ref_data( 32'd1070381968 );
  ref_data(-32'd989883989  );
  ref_data( 32'd1786021934 );
  ref_data( 32'd1661164588 );
  ref_data( 32'd1390010407 );
  ref_data(-32'd1218133724 );
  ref_data(-32'd975993875  );
  ref_data( 32'd1512467795 );
  ref_data(-32'd1305515890 );
  ref_data( 32'd1517666319 );
  ref_data( 32'd1590514341 );
  ref_data(-32'd1234533226 );
  ref_data( 32'd699624414  );
  ref_data( 32'd2036928677 );
  ref_data( 32'd1670669049 );
  ref_data(-32'd1235432265 );
  ref_data( 32'd1555365629 );
  ref_data( 32'd1272522583 );
  ref_data( 32'd1997264332 );
  ref_data( 32'd1220884064 );
  ref_data(-32'd1379114396 );
  ref_data(-32'd2111326676 );
  ref_data( 32'd546260101  );
  ref_data( 32'd937167434  );
  ref_data( 32'd833581709  );
  ref_data(-32'd1635393726 );
  ref_data( 32'd1721904602 );
  ref_data(-32'd557016485  );
  ref_data( 32'd1861641632 );
  ref_data(-32'd883658915  );
  ref_data(-32'd1909144253 );
  ref_data( 32'd2098560112 );
  ref_data(-32'd1249931646 );
  ref_data(-32'd1679142137 );
  ref_data(-32'd893125243  );
  ref_data(-32'd1580488465 );


end
endtask
