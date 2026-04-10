onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /DE1_SoC_tb/CLOCK_50
add wave -noupdate {/DE1_SoC_tb/V_GPIO[29]}
add wave -noupdate /DE1_SoC_tb/dut/reset
add wave -noupdate {/DE1_SoC_tb/V_GPIO[35]}
add wave -noupdate {/DE1_SoC_tb/V_GPIO[24]}
add wave -noupdate /DE1_SoC_tb/dut/inner
add wave -noupdate {/DE1_SoC_tb/V_GPIO[34]}
add wave -noupdate {/DE1_SoC_tb/V_GPIO[23]}
add wave -noupdate /DE1_SoC_tb/dut/outer
add wave -noupdate /DE1_SoC_tb/dut/exit_pulse
add wave -noupdate /DE1_SoC_tb/dut/enter_pulse
add wave -noupdate -radix unsigned /DE1_SoC_tb/dut/count
add wave -noupdate /DE1_SoC_tb/HEX5
add wave -noupdate /DE1_SoC_tb/HEX4
add wave -noupdate /DE1_SoC_tb/HEX3
add wave -noupdate /DE1_SoC_tb/HEX2
add wave -noupdate /DE1_SoC_tb/HEX1
add wave -noupdate /DE1_SoC_tb/HEX0
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {327 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 50
configure wave -gridperiod 100
configure wave -griddelta 2
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2888 ps}
