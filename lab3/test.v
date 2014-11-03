module top;

  logic A;
  logic B;

  initial begin

    A = 1'bx;
    $display( "%b", A );
    if (!A) begin
      B = 1'b0;
    end
    else begin
      B = 1'b1;
    end
    $display( "%b", B );

  end

endmodule
