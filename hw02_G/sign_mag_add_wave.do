onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sign_mag_add_tb/clk
add wave -noupdate /sign_mag_add_tb/N
add wave -noupdate /sign_mag_add_tb/a
add wave -noupdate -radix binary /sign_mag_add_tb/b
add wave -noupdate /sign_mag_add_tb/addr
add wave -noupdate /sign_mag_add_tb/sum
add wave -noupdate /sign_mag_add_tb/data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {94 ps} 0}
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
WaveRestoreZoom {0 ps} {158 ps}
