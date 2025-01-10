import .tc_core show *
import .switch_reset_helper show *
main :

  switchHelper/Switch_resetHelper := Switch_resetHelper
  switchHelper.init
  switchHelper.run "TURN"
  switchHelper.run "RESET"
  switchHelper.run "TURN"
  switchHelper.run "TURN"
  switchHelper.run "RESET"

