import .tc_core show *

//////////////////////////////////////////////////
//  class Switch_resetHelper
//////////////////////////////////////////////////    
class Switch_resetHelper :

  composer_/Switch_resetComposer := Switch_resetComposer
  helper_/QHsmHelper := QHsmHelper "switch"

  constructor :
    create_helper

  create_helper -> none :
    helper_.insert "switch" "init"  (ThreadedCodeExecutor helper_ "off" (composer_.compose "switch.init"))
    helper_.insert "off"    "RESET" (ThreadedCodeExecutor helper_ "off" (composer_.compose "off.RESET"))
    helper_.insert "off"    "TURN"  (ThreadedCodeExecutor helper_ "on"  (composer_.compose "off.TURN"))
    helper_.insert "on"     "RESET" (ThreadedCodeExecutor helper_ "off" (composer_.compose "on.RESET"))
    helper_.insert "on"     "TURN"  (ThreadedCodeExecutor helper_ "off" (composer_.compose "on.TURN"))

  init -> none :
    helper_.post "init" 1

  run eventName/string -> none :
    helper_.post eventName 2

  state -> string :
    return helper_.get_state
    
//////////////////////////////////////////////////
//  class Switch_resetComposer
//////////////////////////////////////////////////          
class Switch_resetComposer : 

  off_entry data/any -> none :
    print "OFF"

  off_reset data/any -> none :
    print "@RESET"

  off_turn data/any -> none :
    print "OFF: TURN"

  on_entry data/any -> none :
    print "ON"

  on_turn data/any -> none :
    print "ON : TURN"

  compose key/string -> List :
    list/List := []
    
    if key == "off.RESET" :
      list.add :: | p | off_reset p
      list.add :: | p | off_entry p
      //print "compose off.RESET [$list.size]"
      return list

    if key == "off.TURN" :
      list.add :: | p | off_turn p
      list.add :: | p | on_entry p
      //print "compose off.TURN [$list.size]"
      return list

    if key == "on.TURN" :
      list.add :: | p | on_turn p
      list.add :: | p | off_entry p
      //print "compose on.TURN [$list.size]"
      return list

    if key == "switch.init" :
      list.add :: | p | off_entry p
      //print "compose switch.init [$list.size]"
      return list;

    if key == "on.RESET" :
      list.add :: | p | off_reset p
      list.add :: | p | off_entry p
      //print "compose on.RESET [$list.size]"
      return list
  
    return list;
