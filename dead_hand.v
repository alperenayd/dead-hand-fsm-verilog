`timescale 1s/1ms
// ============================================================
// dead_hand.v  (STUDENT STARTER CODE)
// BBM233 Logic Design Laboratory
// Final Project: World War III – Dead Hand Protocol
//
// IMPORTANT:
// - Do NOT change module name or port list.
// - clk is 1 Hz (1 tick per second).
// - reset is synchronous, active-high.
// - Implement Main FSM + Engagement Sub-FSM.
// ============================================================

module dead_hand(
    input  wire       clk,
    input  wire       reset,
    input  wire [1:0] threat_level,
    input  wire       diplomatic_override,
    input  wire       comms_lost,
    input  wire       system_fault,

    output reg        armed_out,
    output reg        tracking_out,
    output reg        authorization_out,
    output reg        override_ignored,
    output reg [2:0]  main_state_out,
    output reg [1:0]  sub_state_out,
    output reg [31:0] timer_out
);

    localparam PEACE        = 3'b000;
    localparam ALERT        = 3'b001;
    localparam MOBILIZATION = 3'b010;
    localparam ENGAGEMENT   = 3'b011;
    localparam GLOBAL_WAR   = 3'b101;
    localparam DEADLOCK     = 3'b110;

    localparam ARM       = 2'b00;
    localparam TRACK     = 2'b01;
    localparam AUTHORIZE = 2'b10;
    localparam ABORT     = 2'b11;

    reg [2:0] current_state, next_state;
    reg [1:0] current_sub_state, next_sub_state;

    reg [31:0] threat_timer;
    reg [31:0] sub_timer;

    always @(*) begin
        main_state_out = current_state;
        sub_state_out  = current_sub_state;
        timer_out      = (current_state == ENGAGEMENT) ? sub_timer : threat_timer;

        armed_out         = (current_state == ENGAGEMENT);
        tracking_out      = (current_state == ENGAGEMENT && current_sub_state == TRACK);
        authorization_out = (current_state == ENGAGEMENT && current_sub_state == AUTHORIZE);
    end

    always @(posedge clk) begin
        if (reset) begin
            current_state     <= PEACE;
            current_sub_state <= ABORT;
            threat_timer      <= 0;
            sub_timer         <= 0;
            override_ignored  <= 0;
        end else begin
            current_state     <= next_state;
            current_sub_state <= next_sub_state;

            if (current_state != next_state)
                threat_timer <= 0;
            else begin
                case (current_state)
                    PEACE:
                        threat_timer <= (threat_level >= 2'b01) ? threat_timer + 1 : 0;
                    ALERT:
                        threat_timer <= ((threat_level >= 2'b10) || (threat_level == 2'b00)) ? threat_timer + 1 : 0;
                    MOBILIZATION:
                        threat_timer <= (threat_level <= 2'b01) ? threat_timer + 1 : 0;
                    default:
                        threat_timer <= 0;
                endcase
            end

            if (current_state != ENGAGEMENT || current_sub_state != next_sub_state)
                sub_timer <= 0;
            else
                sub_timer <= sub_timer + 1;

            if (!override_ignored) begin
                if (current_state == DEADLOCK || current_state == GLOBAL_WAR)
                    override_ignored <= 1;
                else if (current_state == ENGAGEMENT &&
                         current_sub_state == AUTHORIZE &&
                         sub_timer >= 2)
                    override_ignored <= 1;
            end
        end
    end

    always @(*) begin
        next_state     = current_state;
        next_sub_state = current_sub_state;

        if (system_fault && current_state != DEADLOCK && current_state != GLOBAL_WAR) begin
            next_state     = GLOBAL_WAR;
            next_sub_state = ABORT;
        end else begin
            case (current_state)

                PEACE:
                    if (threat_level >= 2'b01 && threat_timer >= 4)
                        next_state = ALERT;

                ALERT:
                    if (threat_level >= 2'b10 && threat_timer >= 9)
                        next_state = MOBILIZATION;
                    else if (threat_level == 2'b00 && threat_timer >= 3)
                        next_state = PEACE;

                MOBILIZATION:
                    if (comms_lost || threat_level == 2'b11) begin
                        next_state     = ENGAGEMENT;
                        next_sub_state = ARM;
                    end else if (threat_level <= 2'b01 && threat_timer >= 3)
                        next_state = ALERT;

                ENGAGEMENT: begin
                    case (current_sub_state)
                        ARM:
                            if (diplomatic_override && !override_ignored)
                                next_sub_state = ABORT;
                            else if (sub_timer >= 4)
                                next_sub_state = TRACK;

                        TRACK:
                            if (diplomatic_override && !override_ignored)
                                next_sub_state = ABORT;
                            else if (sub_timer >= 6)
                                next_sub_state = AUTHORIZE;

                        AUTHORIZE:
                            if (diplomatic_override && !override_ignored)
                                next_sub_state = ABORT;
                            else if (sub_timer >= 3)
                                next_state = DEADLOCK;

                        ABORT:
                            if (sub_timer >= 5)
                                next_state = MOBILIZATION;
                    endcase
                end

                DEADLOCK:
                    next_state = DEADLOCK;

                GLOBAL_WAR:
                    next_state = GLOBAL_WAR;

            endcase
        end
    end

endmodule
