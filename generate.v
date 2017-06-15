genvar ii;
generate
    for(ii=0;ii<NUM;ii=ii+1)
        assign dout[i] = din[i];
endgenerate
