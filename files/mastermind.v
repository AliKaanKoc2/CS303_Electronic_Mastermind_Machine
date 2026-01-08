module mastermind(

    input clk,
    input rst,

    input enterA, 
    input enterB, 
    input [2:0] letterIn,           
   
    output reg [7:0] LEDX,
    output reg [6:0] SSD3, 
    output reg [6:0] SSD2, 
    output reg [6:0] SSD1, 
    output reg [6:0] SSD0 
     
    );

// FINALIZED MASTERMIND WITH LED's and SSD's

// States
parameter S_IDLE = 4'b0000, S_SHOW_SCORE = 4'b0001, S_SHOW_PLAYER = 4'b0010, S_CM_INPUT = 4'b0011,S_SHOW_LIVES = 4'b0100,
S_CB_INPUT = 4'b0101, S_COMPARE = 4'b0110, S_CB_WINS = 4'b0111, S_SHOW_SECRET = 4'b1000, S_FINAL_SCORE_FOR_TURN = 4'b1001,
S_SWAP = 4'b1010, S_GAME_OVER = 4'b1011;

parameter MAX_VALUE = 100;

reg [3:0] cState, nState;
reg activePlayer; // 0 -> A         
reg [1:0] lives, scoreA, scoreB, index;
reg [2:0] M1_0, M1_1, M1_2, M1_3, B2_0, B2_1, B2_2, B2_3; 
reg [6:0] timer; 
reg timer_done, timer_start;
reg inputDone;

reg show_feedback;

reg [7:0] stored_leds; 
reg [1:0] led3, led2, led1, led0;

// LED part - since this is not cpp i can write here
always @(*) begin
    // AN3
    if(B2_0 == M1_0) led3 = 2'b11;    // Exact Match
    else if(B2_0 == M1_1 || B2_0 == M1_2 || B2_0 == M1_3) led3 = 2'b01; // Wrong Place
    else led3 = 2'b00;                        

    // AN2
    if(B2_1 == M1_1) led2 = 2'b11; 
    else if(B2_1 == M1_0 || B2_1 == M1_2 || B2_1 == M1_3) led2 = 2'b01; 
    else led2 = 2'b00; 

    // AN1
    if(B2_2 == M1_2) led1 = 2'b11; 
    else if(B2_2 == M1_0 || B2_2 == M1_1 || B2_2 == M1_3) led1 = 2'b01; 
    else led1 = 2'b00; 

    // AN0
    if(B2_3 == M1_3) led0 = 2'b11; 
    else if(B2_3 == M1_0 || B2_3 == M1_1 || B2_3 == M1_2) led0 = 2'b01; 
    else led0 = 2'b00; 
end

// TIMER FSM
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        timer      <= 0;
        timer_done <= 1'b0;
    end
    else begin
        if(!timer_start) begin
            timer      <= 0;
            timer_done <= 1'b0;
        end
        else begin
            if(timer == MAX_VALUE-1)begin
                timer      <= 0;
                timer_done <= 1'b1; 
            end
            else begin
                timer      <= timer + 1;
                timer_done <= 1'b0;
            end
        end
    end
end

always@(posedge clk or negedge rst)
begin
    if(!rst)begin
            cState <= S_IDLE;
            activePlayer <= 1'b0;
            scoreA <= 2'b00; 
            scoreB <= 2'b00; 
            lives <= 2'b11; 
            index <= 2'b00;

            M1_0 <= 3'b000; 
            M1_1 <= 3'b000; 
            M1_2 <= 3'b000; 
            M1_3 <= 3'b000;

            B2_0 <= 3'b000; 
            B2_1 <= 3'b000; 
            B2_2 <= 3'b000; 
            B2_3 <= 3'b000;

            inputDone <= 1'b0;
            stored_leds <= 8'b0; // Reset Memory
            show_feedback <= 1'b0;

        end
    else begin
            cState <= nState;
            case(cState)
                S_IDLE: begin
                        stored_leds <= 8'b0; // Clear LED
                        if(enterA) begin
                            activePlayer <= 1'b0;   
                            scoreA <= 2'b00; scoreB <= 2'b00; lives  <= 2'b11; index  <= 2'b00;
                            show_feedback <= 1'b0;
                        end
                        else if(enterB)begin
                            activePlayer <= 1'b1;   
                            scoreA <= 2'b00; scoreB <= 2'b00; lives  <= 2'b11; index  <= 2'b00;
                        end
                    end
                
                S_SHOW_SCORE: begin 
                    show_feedback <= 1'b0;
                end
                S_SHOW_PLAYER: 
                begin
                    inputDone <= 1'b0;
                    show_feedback <= 1'b0;
                end
                S_CM_INPUT: begin
                        show_feedback <= 1'b0;
                        if(activePlayer == 1'b0 && enterA && letterIn != 3'b000)begin
                            case(index)
                                2'b00: M1_0 <= letterIn;
                                2'b01: M1_1 <= letterIn;
                                2'b10: M1_2 <= letterIn;
                                2'b11: 
                                begin 
                                    M1_3 <= letterIn; inputDone <= 1'b1; 
                                end
                            endcase
                            index <= index + 1'b1;
                        end
                        else if(activePlayer == 1'b1 && enterB && letterIn != 3'b000)begin
                            case(index)
                                2'b00: M1_0 <= letterIn;
                                2'b01: M1_1 <= letterIn;
                                2'b10: M1_2 <= letterIn;
                                2'b11: 
                                begin 
                                    M1_3 <= letterIn; inputDone <= 1'b1; 
                                end
                            endcase
                            index <= index + 1'b1;
                        end
                    end

                S_SHOW_LIVES: begin
                    inputDone <= 1'b0;
                    
                end
                S_CB_INPUT: begin

                        
                        if(activePlayer == 1'b0 && enterB && letterIn != 3'b000)begin
                            stored_leds <= 8'b0;
                            show_feedback <= 1'b0;
                            case(index)
                                2'b00: B2_0 <= letterIn;
                                2'b01: B2_1 <= letterIn;
                                2'b10: B2_2 <= letterIn;
                                2'b11: 
                                begin 
                                    B2_3 <= letterIn; inputDone <= 1'b1; 
                                end
                            endcase
                            index <= index + 1'b1;
                        end 
                        else if(activePlayer == 1'b1 && enterA && letterIn != 3'b000)begin
                            stored_leds <= 8'b0;
                            show_feedback <= 1'b0;
                            case(index)
                                2'b00: B2_0 <= letterIn;
                                2'b01: B2_1 <= letterIn;
                                2'b10: B2_2 <= letterIn;
                                2'b11: 
                                begin 
                                    B2_3 <= letterIn; inputDone <= 1'b1; 
                                end
                            endcase
                            index <= index + 1'b1;
                        end
                    end
                
                S_COMPARE: begin
                    index <= 2'b00;

                    //Save led
                    stored_leds <= {led3, led2, led1, led0};
                    show_feedback <= 1'b1;

                    if( (M1_0 == B2_0) && (M1_1 == B2_1) && (M1_2 == B2_2) && (M1_3 == B2_3)) begin
                        if(activePlayer == 1'b0) scoreB <= scoreB + 1'b1;
                        else scoreA <= scoreA + 1'b1;
                    end
                    else begin
                        lives <= lives - 1'b1;
                        if(lives == 2'b01)begin
                            if(activePlayer == 1'b0) scoreA <= scoreA + 1'b1;
                            else scoreB <= scoreB + 1'b1;
                        end
                    end
                end

                S_CB_WINS:
                begin 
 
                end

                S_SHOW_SECRET: 
                begin 
 
                end

                S_FINAL_SCORE_FOR_TURN:
                begin 
 
                end

                S_SWAP: begin
                    activePlayer <= ~activePlayer;

                    lives <= 2'b11; 
                    
                    index <= 2'b00;

                    M1_0 <= 3'b000; 
                    M1_1 <= 3'b000; 
                    M1_2 <= 3'b000; 
                    M1_3 <= 3'b000;

                    B2_0 <= 3'b000; 
                    B2_1 <= 3'b000; 
                    B2_2 <= 3'b000; 
                    B2_3 <= 3'b000;

                    stored_leds <= 8'b0; 
                    show_feedback <= 1'b0;
                end
                
                S_GAME_OVER: 
                begin 
 
                end

                default: 
                begin 
 
                end
                
            endcase
    end
end

always@(*)begin
    nState = cState;
    timer_start = 1'b0;

    case(cState)
        S_IDLE: if(enterA || enterB) nState = S_SHOW_SCORE;

        S_SHOW_SCORE: 
        begin 
            timer_start = 1'b1; 
            if(timer_done) nState = S_SHOW_PLAYER; 
        end

        S_SHOW_PLAYER: 
        begin 
            timer_start = 1'b1; 
            if(timer_done) nState = S_CM_INPUT; 
        end

        S_CM_INPUT: begin
        if(inputDone) nState = S_SHOW_LIVES;
        end

        S_SHOW_LIVES: 
        begin 
            begin 
                timer_start = 1'b1; 
                if(timer_done) begin
                    if(lives == 2'b00)      // Lives was decremented to 0 in S_COMPARE
                        nState = S_SHOW_SECRET;
                    else
                        nState = S_CB_INPUT;
                end
            end
        end

        S_CB_INPUT: if(inputDone) nState = S_COMPARE;

        S_COMPARE: begin
           
            if((M1_0 == B2_0) && (M1_1 == B2_1) && (M1_2 == B2_2) && (M1_3 == B2_3)) nState = S_CB_WINS;
            else  nState = S_SHOW_LIVES;
            
        end

        S_CB_WINS: if((activePlayer == 1'b0 && enterB) || (activePlayer == 1'b1 && enterA)) nState = S_FINAL_SCORE_FOR_TURN;

        S_SHOW_SECRET: 
        begin 
            if( (activePlayer == 1'b0 && enterB) || (activePlayer == 1'b1 && enterA) ) 
                    nState = S_FINAL_SCORE_FOR_TURN; 
        end

        S_FINAL_SCORE_FOR_TURN:
        begin
            timer_start = 1'b1;

            if(timer_done)begin
                if(scoreA == 2'b10 || scoreB == 2'b10) nState = S_GAME_OVER;
                else nState = S_SWAP;
            end

        end
        S_SWAP: 
            nState = S_SHOW_PLAYER;

        S_GAME_OVER: 
        begin 
            timer_start = 1'b1; if(timer_done) nState = S_IDLE; 
        end

        default: nState = S_IDLE;
    endcase
end


// Output helper
parameter NUM_0  = 7'b0111111; 
parameter NUM_1  = 7'b0000110; 
parameter NUM_2  = 7'b1011011; 
parameter NUM_3  = 7'b1001111; 

parameter CHAR_A = 7'b1110111;
parameter CHAR_b = 7'b1111100;
parameter CHAR_C = 7'b0111001;
parameter CHAR_E = 7'b1111001;
parameter CHAR_F = 7'b1110001;
parameter CHAR_H = 7'b1110110;
parameter CHAR_L = 7'b0111000;
parameter CHAR_P = 7'b1110011;
parameter CHAR_U = 7'b0111110;
parameter DASH   = 7'b1000000;
parameter blank  = 7'b0000000;

always@(*)
begin
    SSD3 = 7'b0000000; SSD2 = 7'b0000000; SSD1 = 7'b0000000; SSD0 = 7'b0000000;
    
    LEDX = blank;

    case(cState)

        S_IDLE: begin // Display "A - b"
            LEDX = blank; // LED off
            SSD3 = blank; SSD2 = CHAR_A; SSD1 = DASH; SSD0 = CHAR_b; 
        end

        S_SHOW_SCORE: begin
            LEDX = blank; // LED off
            SSD3 = blank;
            case(scoreA) 

                2'b00: SSD2 = NUM_0; 
                2'b01: SSD2 = NUM_1; 
                2'b10: SSD2 = NUM_2; 
                2'b11: SSD2 = NUM_3; 

                default: SSD2 = blank; 

            endcase

            SSD1 = DASH; 

            case(scoreB) 

                2'b00: SSD0 = NUM_0; 
                2'b01: SSD0 = NUM_1; 
                2'b10: SSD0 = NUM_2; 
                2'b11: SSD0 = NUM_3; 

                default: SSD0 = blank; 

            endcase
        end

        S_SHOW_PLAYER:begin
            LEDX = blank;

            SSD3 = blank; 
            SSD2 = CHAR_P; 
            SSD1 = DASH;

            if(activePlayer == 1'b0) SSD0 = CHAR_A; 
            else SSD0 = CHAR_b;

        end

        S_CM_INPUT:begin
            LEDX = blank; // Force LEDs OFF while Code Maker types

            if(inputDone) begin
                SSD3 = blank; SSD2 = blank; SSD1 = blank; SSD0 = blank;
            end
            else begin

                case(index)

                    2'b00: begin 

                        case(letterIn) 
                        
                            3'b001: SSD3 = CHAR_A; 
                            3'b010: SSD3 = CHAR_C; 
                            3'b011: SSD3 = CHAR_E; 
                            3'b100: SSD3 = CHAR_F; 
                            3'b101: SSD3 = CHAR_H; 
                            3'b110: SSD3 = CHAR_L; 
                            3'b111: SSD3 = CHAR_U; 
                            default: SSD3 = blank; 
                            
                        endcase

                    end
                    2'b01: begin 

                        case(letterIn) 
                            3'b001: SSD2 = CHAR_A; 
                            3'b010: SSD2 = CHAR_C; 
                            3'b011: SSD2 = CHAR_E; 
                            3'b100: SSD2 = CHAR_F; 
                            3'b101: SSD2 = CHAR_H; 
                            3'b110: SSD2 = CHAR_L; 
                            3'b111: SSD2 = CHAR_U; 
                            default: SSD2 = blank; 
                        endcase

                        SSD3 = DASH; // -A** for example

                    end
                    2'b10: begin 

                        case(letterIn) 
                            3'b001: SSD1 = CHAR_A; 
                            3'b010: SSD1 = CHAR_C; 
                            3'b011: SSD1 = CHAR_E; 
                            3'b100: SSD1 = CHAR_F; 
                            3'b101: SSD1 = CHAR_H; 
                            3'b110: SSD1 = CHAR_L; 
                            3'b111: SSD1 = CHAR_U; 
                            default: SSD1 = blank; 
                        endcase

                        SSD3 = DASH; 
                        SSD2 = DASH; 
                                    // --A*
                    end
                    2'b11: // ---A
                    begin 
                        case(letterIn) 
                            3'b001: SSD0 = CHAR_A; 
                            3'b010: SSD0 = CHAR_C; 
                            3'b011: SSD0 = CHAR_E; 
                            3'b100: SSD0 = CHAR_F; 
                            3'b101: SSD0 = CHAR_H; 
                            3'b110: SSD0 = CHAR_L; 
                            3'b111: SSD0 = CHAR_U; 
                            default: SSD0 = blank; 
                        endcase

                        SSD3 = DASH; 
                        SSD2 = DASH; 
                        SSD1 = DASH; 

                    end

                endcase
            end
        end

        S_SHOW_LIVES: begin
            LEDX = stored_leds;
            
            if(lives == 2'b00) begin
                // Show the wrong guess, not "L-0"
                case(B2_0) 
                    3'b001: SSD3 = CHAR_A; 
                    3'b010: SSD3 = CHAR_C; 
                    3'b011: SSD3 = CHAR_E; 
                    3'b100: SSD3 = CHAR_F; 
                    3'b101: SSD3 = CHAR_H; 
                    3'b110: SSD3 = CHAR_L; 
                    3'b111: SSD3 = CHAR_U; 
                    default: SSD3 = blank; 
                endcase
                case(B2_1) 
                    3'b001: SSD2 = CHAR_A; 
                    3'b010: SSD2 = CHAR_C; 
                    3'b011: SSD2 = CHAR_E; 
                    3'b100: SSD2 = CHAR_F; 
                    3'b101: SSD2 = CHAR_H; 
                    3'b110: SSD2 = CHAR_L; 
                    3'b111: SSD2 = CHAR_U; 
                    default: SSD2 = blank; 
                endcase
                case(B2_2) 
                    3'b001: SSD1 = CHAR_A; 
                    3'b010: SSD1 = CHAR_C; 
                    3'b011: SSD1 = CHAR_E; 
                    3'b100: SSD1 = CHAR_F; 
                    3'b101: SSD1 = CHAR_H; 
                    3'b110: SSD1 = CHAR_L; 
                    3'b111: SSD1 = CHAR_U; 
                    default: SSD1 = blank; 
                endcase
                case(B2_3) 
                    3'b001: SSD0 = CHAR_A; 
                    3'b010: SSD0 = CHAR_C; 
                    3'b011: SSD0 = CHAR_E; 
                    3'b100: SSD0 = CHAR_F; 
                    3'b101: SSD0 = CHAR_H; 
                    3'b110: SSD0 = CHAR_L; 
                    3'b111: SSD0 = CHAR_U; 
                    default: SSD0 = blank; 
                endcase
            end
            else begin
                // Normal: show "L-3", "L-2", "L-1"
                SSD3 = blank; 
                SSD2 = CHAR_L; 
                SSD1 = DASH;   
                case(lives) 
                    2'b01: SSD0 = NUM_1; 
                    2'b10: SSD0 = NUM_2; 
                    2'b11: SSD0 = NUM_3; 
                    default: SSD0 = blank; 
                endcase
            end
        end

        S_CB_INPUT: begin
            
            LEDX = 8'b0;
            if(inputDone) begin
                SSD3 = blank; SSD2 = blank; SSD1 = blank; SSD0 = blank;
            end
            else begin
            
                if(index == 0)begin 

                    case(letterIn)
                        3'b001: SSD3 = CHAR_A; 
                        3'b010: SSD3 = CHAR_C; 
                        3'b011: SSD3 = CHAR_E; 
                        3'b100: SSD3 = CHAR_F; 
                        3'b101: SSD3 = CHAR_H; 
                        3'b110: SSD3 = CHAR_L; 
                        3'b111: SSD3 = CHAR_U; 
                        default: SSD3 = blank;
                    endcase

                end else begin

                    // Show stored First Letter (B2_0) on SSD3
                    case(B2_0)
                        3'b001: SSD3 = CHAR_A; 
                        3'b010: SSD3 = CHAR_C; 
                        3'b011: SSD3 = CHAR_E; 
                        3'b100: SSD3 = CHAR_F; 
                        3'b101: SSD3 = CHAR_H; 
                        3'b110: SSD3 = CHAR_L; 
                        3'b111: SSD3 = CHAR_U; 
                        default: SSD3 = blank;
                    endcase            
                end

                if(index == 1)begin 
                    case(letterIn) 
                        3'b001: SSD2 = CHAR_A; 
                        3'b010: SSD2 = CHAR_C; 
                        3'b011: SSD2 = CHAR_E; 
                        3'b100: SSD2 = CHAR_F; 
                        3'b101: SSD2 = CHAR_H; 
                        3'b110: SSD2 = CHAR_L; 
                        3'b111: SSD2 = CHAR_U; 
                        default: SSD2 = blank; 
                    endcase            
                end else if (index > 1) begin
                    case(B2_1) 
                        3'b001: SSD2 = CHAR_A; 
                        3'b010: SSD2 = CHAR_C; 
                        3'b011: SSD2 = CHAR_E; 
                        3'b100: SSD2 = CHAR_F; 
                        3'b101: SSD2 = CHAR_H; 
                        3'b110: SSD2 = CHAR_L; 
                        3'b111: SSD2 = CHAR_U; 
                        default: SSD2 = blank; 
                    endcase            
                end

                if(index == 2)begin 
                    case(letterIn) 
                        3'b001: SSD1 = CHAR_A; 
                        3'b010: SSD1 = CHAR_C; 
                        3'b011: SSD1 = CHAR_E; 
                        3'b100: SSD1 = CHAR_F; 
                        3'b101: SSD1 = CHAR_H; 
                        3'b110: SSD1 = CHAR_L; 
                        3'b111: SSD1 = CHAR_U; 
                        default: SSD1 = blank; 
                    endcase            

                end else if (index > 2) begin
                    case(B2_2) 
                        3'b001: SSD1 = CHAR_A; 
                        3'b010: SSD1 = CHAR_C; 
                        3'b011: SSD1 = CHAR_E; 
                        3'b100: SSD1 = CHAR_F; 
                        3'b101: SSD1 = CHAR_H; 
                        3'b110: SSD1 = CHAR_L; 
                        3'b111: SSD1 = CHAR_U; 
                        default: SSD1 = blank; 
                    endcase            
                end

                if(index == 3)begin 
                    case(letterIn) 
                        3'b001: SSD0 = CHAR_A; 
                        3'b010: SSD0 = CHAR_C; 
                        3'b011: SSD0 = CHAR_E; 
                        3'b100: SSD0 = CHAR_F; 
                        3'b101: SSD0 = CHAR_H; 
                        3'b110: SSD0 = CHAR_L; 
                        3'b111: SSD0 = CHAR_U; 
                        default: SSD0 = blank; 
                    endcase            
                end else if (index > 3) begin
                    case(B2_3) 
                        3'b001: SSD0 = CHAR_A; 
                        3'b010: SSD0 = CHAR_C; 
                        3'b011: SSD0 = CHAR_E; 
                        3'b100: SSD0 = CHAR_F; 
                        3'b101: SSD0 = CHAR_H; 
                        3'b110: SSD0 = CHAR_L; 
                        3'b111: SSD0 = CHAR_U; 
                        default: SSD0 = blank; 
                    endcase            
                end
            end
        end

        S_COMPARE:begin
            // Use stored_leds (Default)
            // Show Guess
            LEDX = stored_leds;
            case(B2_0) 
                3'b001: SSD3 = CHAR_A; 
                3'b010: SSD3 = CHAR_C; 
                3'b011: SSD3 = CHAR_E; 
                3'b100: SSD3 = CHAR_F; 
                3'b101: SSD3 = CHAR_H; 
                3'b110: SSD3 = CHAR_L; 
                3'b111: SSD3 = CHAR_U; 
                default: SSD3 = blank; 
            endcase

            case(B2_1) 
                3'b001: SSD2 = CHAR_A; 
                3'b010: SSD2 = CHAR_C; 
                3'b011: SSD2 = CHAR_E; 
                3'b100: SSD2 = CHAR_F; 
                3'b101: SSD2 = CHAR_H; 
                3'b110: SSD2 = CHAR_L; 
                3'b111: SSD2 = CHAR_U; 
                default: SSD2 = blank; 
            endcase

            case(B2_2) 
                3'b001: SSD1 = CHAR_A; 
                3'b010: SSD1 = CHAR_C; 
                3'b011: SSD1 = CHAR_E; 
                3'b100: SSD1 = CHAR_F; 
                3'b101: SSD1 = CHAR_H; 
                3'b110: SSD1 = CHAR_L; 
                3'b111: SSD1 = CHAR_U; 
                default: SSD1 = blank; 
            endcase

            case(B2_3) 
                3'b001: SSD0 = CHAR_A; 
                3'b010: SSD0 = CHAR_C; 
                3'b011: SSD0 = CHAR_E; 
                3'b100: SSD0 = CHAR_F; 
                3'b101: SSD0 = CHAR_H; 
                3'b110: SSD0 = CHAR_L; 
                3'b111: SSD0 = CHAR_U; 
                default: SSD0 = blank; 
            endcase

        end

        S_CB_WINS:begin
            LEDX = stored_leds;
            // Use stored_leds (Default)
            case(B2_0) 
                3'b001: SSD3 = CHAR_A; 
                3'b010: SSD3 = CHAR_C; 
                3'b011: SSD3 = CHAR_E; 
                3'b100: SSD3 = CHAR_F; 
                3'b101: SSD3 = CHAR_H; 
                3'b110: SSD3 = CHAR_L; 
                3'b111: SSD3 = CHAR_U; 
                default: SSD3 = blank; 
            endcase

            case(B2_1) 
                3'b001: SSD2 = CHAR_A; 
                3'b010: SSD2 = CHAR_C; 
                3'b011: SSD2 = CHAR_E; 
                3'b100: SSD2 = CHAR_F; 
                3'b101: SSD2 = CHAR_H; 
                3'b110: SSD2 = CHAR_L; 
                3'b111: SSD2 = CHAR_U; 
                default: SSD2 = blank; 
            endcase

            case(B2_2) 
                3'b001: SSD1 = CHAR_A; 
                3'b010: SSD1 = CHAR_C; 
                3'b011: SSD1 = CHAR_E; 
                3'b100: SSD1 = CHAR_F; 
                3'b101: SSD1 = CHAR_H; 
                3'b110: SSD1 = CHAR_L; 
                3'b111: SSD1 = CHAR_U; 
                default: SSD1 = blank; 
            endcase

            case(B2_3) 
                3'b001: SSD0 = CHAR_A; 
                3'b010: SSD0 = CHAR_C; 
                3'b011: SSD0 = CHAR_E; 
                3'b100: SSD0 = CHAR_F; 
                3'b101: SSD0 = CHAR_H; 
                3'b110: SSD0 = CHAR_L; 
                3'b111: SSD0 = CHAR_U; 
                default: SSD0 = blank; 
            endcase        

        end

        S_SHOW_SECRET: begin

            LEDX = 8'b0;

            case(M1_0) 
                3'b001: SSD3 = CHAR_A; 
                3'b010: SSD3 = CHAR_C; 
                3'b011: SSD3 = CHAR_E; 
                3'b100: SSD3 = CHAR_F; 
                3'b101: SSD3 = CHAR_H; 
                3'b110: SSD3 = CHAR_L; 
                3'b111: SSD3 = CHAR_U; 
                default: SSD3 = blank; 
            endcase

            case(M1_1) 
                3'b001: SSD2 = CHAR_A; 
                3'b010: SSD2 = CHAR_C; 
                3'b011: SSD2 = CHAR_E; 
                3'b100: SSD2 = CHAR_F; 
                3'b101: SSD2 = CHAR_H; 
                3'b110: SSD2 = CHAR_L; 
                3'b111: SSD2 = CHAR_U; 
                default: SSD2 = blank; 
            endcase

            case(M1_2) 
                3'b001: SSD1 = CHAR_A; 
                3'b010: SSD1 = CHAR_C; 
                3'b011: SSD1 = CHAR_E; 
                3'b100: SSD1 = CHAR_F; 
                3'b101: SSD1 = CHAR_H; 
                3'b110: SSD1 = CHAR_L; 
                3'b111: SSD1 = CHAR_U; 
                default: SSD1 = blank; 
            endcase

            case(M1_3) 
                3'b001: SSD0 = CHAR_A; 
                3'b010: SSD0 = CHAR_C; 
                3'b011: SSD0 = CHAR_E; 
                3'b100: SSD0 = CHAR_F; 
                3'b101: SSD0 = CHAR_H; 
                3'b110: SSD0 = CHAR_L; 
                3'b111: SSD0 = CHAR_U; 
                default: SSD0 = blank; 
            endcase
        end

        S_FINAL_SCORE_FOR_TURN: begin
            LEDX = blank;
            SSD3 = blank; 
            case(scoreA) 
                2'b00: SSD2 = NUM_0; 
                2'b01: SSD2 = NUM_1; 
                2'b10: SSD2 = NUM_2; 
                default: SSD2 = blank; 
            endcase

            SSD1 = DASH;

            case(scoreB) 
                2'b00: SSD0 = NUM_0; 
                2'b01: SSD0 = NUM_1; 
                2'b10: SSD0 = NUM_2; 
                default: SSD0 = blank; 
            endcase
        end

        S_GAME_OVER: begin
            SSD3 = blank;

            case(scoreA) 
                2'b00: SSD2 = NUM_0; 
                2'b01: SSD2 = NUM_1; 
                2'b10: SSD2 = NUM_2; 
                default: SSD2 = blank; 
            endcase

            SSD1 = DASH;

            case(scoreB) 
                2'b00: SSD0 = NUM_0; 
                2'b01: SSD0 = NUM_1; 
                2'b10: SSD0 = NUM_2; 
                default: SSD0 = blank; 
            endcase
            
            // Blink all LEDs
            if(timer[0] == 1'b1) LEDX = 8'b11111111;
            else LEDX = 8'b00000000;
        end

        default:
        begin
            SSD3 = blank; SSD2 = blank; SSD1 = blank; SSD0 = blank;
            LEDX = blank;
        end
    endcase
end   
endmodule