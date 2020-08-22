# Copyright 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

read_liberty $::env(LIB_SYNTH)

if {[catch {read_lef $::env(MERGED_LEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

read_verilog $::env(yosys_result_file_tag).v
link_design $::env(DESIGN_NAME)
set bottom_margin  [expr $::env(PLACE_SITE_HEIGHT) * $::env(BOTTOM_MARGIN_MULT)]
set top_margin  [expr $::env(PLACE_SITE_HEIGHT) * $::env(TOP_MARGIN_MULT)]
set left_margin [expr $::env(PLACE_SITE_WIDTH) * $::env(LEFT_MARGIN_MULT)]
set right_margin [expr $::env(PLACE_SITE_WIDTH) * $::env(RIGHT_MARGIN_MULT)]


if {$::env(FP_SIZING) == "absolute"} {
  set die_ll_x [lindex $::env(DIE_AREA) 0]
  set die_ll_y [lindex $::env(DIE_AREA) 1]
  set die_ur_x [lindex $::env(DIE_AREA) 2]
  set die_ur_y [lindex $::env(DIE_AREA) 3]

  set core_ll_x [expr {$die_ll_x + $left_margin}]
  set core_ll_y [expr {$die_ll_y + $bottom_margin}]
  set core_ur_x [expr {$die_ur_x - $right_margin}]
  set core_ur_y [expr {$die_ur_y - $top_margin}]

  set ::env(CORE_AREA) [list $core_ll_x $core_ll_y $core_ur_x $core_ur_y]


  initialize_floorplan \
    -die_area $::env(DIE_AREA) \
    -core_area $::env(CORE_AREA) \
    -tracks $::env(TRACKS_INFO_FILE) \
    -site $::env(PLACE_SITE)
} else {
  initialize_floorplan \
    -utilization $::env(FP_CORE_UTIL) \
    -aspect_ratio $::env(FP_ASPECT_RATIO) \
    -core_space "$bottom_margin $top_margin $left_margin $right_margin" \
    -tracks $::env(TRACKS_INFO_FILE) \
    -site $::env(PLACE_SITE)
}

write_def $::env(SAVE_DEF)
