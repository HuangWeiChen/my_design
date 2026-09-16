//`timescale 1ns/100ps
module change(
    input logic clk,
    input logic rst,
    input logic [5:0] coin_in,
    input logic trg_finish,
    output logic product,
    output logic [5:0] change_10,
    output logic [5:0] change_5,
    output logic [5:0] change_1
    );

    typedef enum{
        start, put_change, forchange_10, forchange_5, forchange_1, finish
    } fsm_state;

    fsm_state fsm_ps, fsm_ns;

    logic [6:0] total_money;
    logic [6:0] total_money_next;
    logic [5:0] change_10_next;
    logic [5:0] change_5_next;
    logic [5:0] change_1_next;
    logic product_next;

    always_ff@(posedge clk) begin
        if(rst)
        begin
            fsm_ps      <= start;
            total_money <= 0;
            change_10   <= 0;
            change_5    <= 0;
            change_1    <= 0;
            product     <= 0;
        end
        else
        begin
            fsm_ps      <= fsm_ns;
            total_money <= total_money_next;
            change_10   <= change_10_next;
            change_5    <= change_5_next;
            change_1    <= change_1_next;
            product     <= product_next;
        end
    end

    always_comb
    begin
        fsm_ns           = fsm_ps;
        total_money_next = total_money;
        change_10_next   = change_10;
        change_5_next    = change_5;
        change_1_next    = change_1;
        product_next     = product;

        case(fsm_ps)
            start:
            begin
                total_money_next = 0;
                change_10_next   = 0;
                change_5_next    = 0;
                change_1_next    = 0;
                product_next     = 0;
                fsm_ns  = put_change;
            end
            put_change:
            begin
                if(trg_finish)
                begin
                    fsm_ns           = forchange_10;
                    total_money_next = total_money - 15;
                end
                else
                begin
                    total_money_next = total_money + coin_in;
                end
            end
            forchange_10:
            begin
                if(total_money >= 20)
                begin
                    total_money_next = total_money - 10;
                    fsm_ns           = forchange_10;
                    change_10_next   = change_10 + 1;
                end
                else if(total_money >= 10)
                begin
                    total_money_next = total_money - 10;
                    fsm_ns           = forchange_5;
                    change_10_next   = change_10 + 1;
                end
                else
                begin
                    fsm_ns           = forchange_5;
                    total_money_next = total_money;
                end
            end
            forchange_5:
            begin
                if(total_money >= 10)
                begin
                    total_money_next = total_money - 5;
                    fsm_ns           = forchange_5;
                    change_5_next    = change_5 + 1;
                end
                else if(total_money >= 5)
                begin
                    total_money_next = total_money - 5;
                    fsm_ns           = forchange_1;
                    change_5_next    = change_5 + 1;
                end
                else
                begin
                    fsm_ns           = forchange_1;
                    total_money_next = total_money;
                end
            end
            forchange_1:
            begin
                if(total_money >= 1)
                begin
                    total_money_next = total_money - 1;
                    fsm_ns           = forchange_1;
                    change_1_next    = change_1 + 1;
                end
                else
                begin
						  product_next = 1;
                    fsm_ns = finish;
                end
            end
            finish:
            begin
					if(trg_finish)
						fsm_ns = finish;
               else
						fsm_ns = start;
            end
        endcase
    end
endmodule