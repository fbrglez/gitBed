proc format.pretty {float {precisionMax 0}} {
    # This idea is based on "shimmer-free" formatting:
    # see http://wiki.tcl.tk/8352
    # In the Tcl Chatroom, 2014-07-17, AM pointed out that the following 
    # operation can be used to set the string value of a floating point number 
    # to a precision of 2 without losing its internal numeric representation:
    # % expr {int(100*111186.0457 + 0.5)/100.0}
    # 111186.05
    # An equivalent operation using round:
    # % expr {round(100*111186.0457)/100.0}
    # 111186.05
    #
    # Generalized and implemented as an extension to expr:
    if {$precisionMax == 0} {return [expr {round($float)}]}
    if {$precisionMax < 0} {
        error "\nERROR from format.pretty:\
          \n.. value of precisionMax=$precisionMax should always be >= 0\n"
    }
    set floatBnd [expr {10**$precisionMax}]
    if {$float < 0.0} {
        set isNegative 1 ; set float [expr {-1.*$float}]
    } else {
        set isNegative 0
    }
    for {set precision 0} {$precision <= $precisionMax} {incr precision} {
        
         set LB [expr {10.0**($precisionMax - $precision - 1)}]
         set UB [expr {10.0**($precisionMax - $precision)}]
         
        if {$float > $LB && $float <= $UB} {
            set number [expr {round( 10 ** $precision * $float) / \
              (10.0 ** $precision)}] ; break

        } elseif {$precision == $precisionMax} {
            set number [expr {round( 10 ** $precisionMax * $float) / \
              (10.0 ** $precisionMax)}] ; break
 
        } elseif {$float > $floatBnd} {
            set number [expr {round($float)}] ; break
        }
    }
    if {$isNegative} {
        return -$number
    } else {
        return $number
    }
#~dd
# % format.pretty -1111.6667888 3
# -1112
# % format.pretty -911.6667888 3
# -912.0
# % format.pretty -91.6667888 3
# -91.7
# % format.pretty -9.6667888 3
# -9.67
# % format.pretty -0.6667888 3
# -0.667
# 
# % format.pretty 0.6667888 3
# 0.667
# % format.pretty 1.6667888 3
# 1.67
# % format.pretty 11.6667888 3
# 11.7
# % format.pretty 111.6667888 3
# 112.0
# % format.pretty 1111.6667888 3
# 1112
# % format.pretty 1111.6667888 0
# 1112
# % format.pretty 1111.6667888 
# 1112
# % format.pretty 1111.6667888 -1
# ERROR from format.pretty: 
# .. value of precisionMax=-1 should always be >= 0
# % 
# Copyright: 
# Franc Brglez, Tue May 19 11:43:41 EDT 2015
#~dd    
} ;# format.pretty

proc format.decimalPlaces { number decimalPlaces } {
  # $number is assumed to be a floating point number in some format,
  # Return $number formatted so that it is accurate to the appropriate
  # number of decimal places.
  #
  # @author Matt Stallmann, 27 April, 2003

  if { ! [string is double -strict $number] } {
    puts stderr "Warning: expected number for %V but got $number"
    return $number
  }

  # $quotient keeps track of what remains after $number is divided by 10
  # some number of times
  set quotient [expr {abs($number)}]
  set fieldWidth [expr {$decimalPlaces + 1}]
  for { set precision [expr {$decimalPlaces - 1}] }\
      { $precision > 0 } { incr precision -1 } {
    if { $quotient < 10 } {
      return [format "%${fieldWidth}.${precision}f" $number]
    }
    set quotient [expr {$quotient / 10}]
  }
  return [format "%${fieldWidth}.0f" $number]

} ;# format.decimalPlaces

proc format.integerPositions {Integer NumPositions} {
    set Label [format "%0${NumPositions}d" $Integer]
    return $Label
#######################################
#                                     #
#   Integer=123 ... NumPositions=5    #
#   ..Label=00123                     #
#                                     #
#   Integer=123 ... NumPositions=2    #
#   ..Label=123                       #
#                                     #
#######################################
} ;# format.IntegerPositions