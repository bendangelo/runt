#!/usr/bin/env ruby

# :title:Runt -- Ruby Temporal Expressions
#
# == Runt -- Ruby Temporal Expressions
#
# The usage and design patterns expressed in this library are mostly...*uhm*..
# <em>entirely</em>..*cough*...based on a series of
# <tt>articles</tt>[http://www.martinfowler.com] by Martin Fowler.
#
# It highly recommended that anyone using Runt (or writing
# object-oriented software :) take a moment to peruse the wealth of useful info
# that Fowler has made publicly available:
#
# * An excellent introductory summation of temporal <tt>patterns</tt>[http://martinfowler.com/ap2/timeNarrative.html]
# * Recurring event <tt>pattern</tt>[http://martinfowler.com/apsupp/recurring.pdf]
#
# Also, for those of you (like me, for example) still chained in your cubicle and forced
# to write <tt>Java</tt>[http://java.sun.com] code, check out the original version of
# project called <tt>ChronicJ</tt>[http://chronicj.org].
#
# ---
# Author::    Matthew Lipper (mailto:mlipper@gmail.com)
# Copyright:: Copyright (c) 2004 Digital Clash, LLC
# License::   See LICENSE.txt
#
# = Warranty
#
# This software is provided "as is" and without any express or
# implied warranties, including, without limitation, the implied
# warranties of merchantibility and fitness for a particular
# purpose.

require 'refine_date'

require 'yaml'
require 'time'
require 'date'
require "runt/version"
require "runt/dprecision"
require "runt/pdate"
require "runt/temporalexpression"
require "runt/schedule"
require "runt/daterange"
require "runt/sugar"
require "runt/expressionbuilder"

#
# The Runt module is the main namespace for all Runt modules and classes. Using
# require statements, it makes the entire Runt library available.It also
# defines some new constants and exposes some already defined in the standard
# library classes <tt>Date</tt> and <tt>DateTime</tt>.
#
# <b>See also</b> runt/sugar_rb which re-opens this module and adds
# some additional functionality
#
# <b>See also</b> date.rb
#
module Runt

  class << self

    def day_name(number)
      Date::DAYNAMES[number]
    end

    def month_name(number)
      # NOTE: first element is nil
      # Jan => 1 (non-zero based)
      Date::MONTHNAMES[number]
    end

    def format_time(date)
      date.strftime('%I:%M%p')
    end

    def format_date(date)
      date.ctime
    end

    #
    # Cut and pasted from activesupport-1.2.5/lib/inflector.rb
    #
    def ordinalize(number)
      if (number.to_i==-1)
	'last'
      elsif (number.to_i==-2)
	'second to last'
      elsif (11..13).include?(number.to_i % 100)
	"#{number}th"
      else
	case number.to_i % 10
	  when 1 then "#{number}st"
	  when 2 then "#{number}nd"
	  when 3 then "#{number}rd"
	  else    "#{number}th"
	end
      end
    end

  end

  #Yes it's true, I'm a big idiot!
  Sunday = Date::DAYNAMES.index("Sunday")
  Monday = Date::DAYNAMES.index("Monday")
  Tuesday = Date::DAYNAMES.index("Tuesday")
  Wednesday = Date::DAYNAMES.index("Wednesday")
  Thursday = Date::DAYNAMES.index("Thursday")
  Friday = Date::DAYNAMES.index("Friday")
  Saturday = Date::DAYNAMES.index("Saturday")
  Sun = Date::ABBR_DAYNAMES.index("Sun")
  Mon = Date::ABBR_DAYNAMES.index("Mon")
  Tue = Date::ABBR_DAYNAMES.index("Tue")
  Wed = Date::ABBR_DAYNAMES.index("Wed")
  Thu = Date::ABBR_DAYNAMES.index("Thu")
  Fri = Date::ABBR_DAYNAMES.index("Fri")
  Sat = Date::ABBR_DAYNAMES.index("Sat")
  January = Date::MONTHNAMES.index("January")
  February = Date::MONTHNAMES.index("February")
  March = Date::MONTHNAMES.index("March")
  April = Date::MONTHNAMES.index("April")
  May = Date::MONTHNAMES.index("May")
  June = Date::MONTHNAMES.index("June")
  July = Date::MONTHNAMES.index("July")
  August = Date::MONTHNAMES.index("August")
  September = Date::MONTHNAMES.index("September")
  October = Date::MONTHNAMES.index("October")
  November = Date::MONTHNAMES.index("November")
  December = Date::MONTHNAMES.index("December")
  First = 1
  Second = 2
  Third = 3
  Fourth = 4
  Fifth = 5
  Sixth = 6
  Seventh = 7
  Eighth = 8
  Eigth = 8  # Will be removed in v0.9.0
  Ninth = 9
  Tenth = 10

  private
  class ApplyLast #:nodoc:
    def initialize
      @negate=Proc.new{|n| n*-1}
    end
    def [](arg)
      @negate.call(arg)
    end
  end
  LastProc = ApplyLast.new

  public
  Last = LastProc[First]
  Last_of = LastProc[First]
  Second_to_last = LastProc[Second]

end

#
# Useful shortcuts!
#
# Contributed by Ara T. Howard who is pretty sure he got the idea from
# somewhere else. :-)
#
class Numeric #:nodoc:
  def microseconds() Float(self  * (10 ** -6)) end unless self.instance_methods.include?('microseconds')
  def milliseconds() Float(self  * (10 ** -3)) end unless self.instance_methods.include?('milliseconds')
  def seconds() self end unless self.instance_methods.include?('seconds')
  def minutes() 60 * seconds end unless self.instance_methods.include?('minutes')
  def hours() 60 * minutes end unless self.instance_methods.include?('hours')
  def days() 24 * hours end unless self.instance_methods.include?('days')
  def weeks() 7 * days end unless self.instance_methods.include?('weeks')
  def months() 30 * days end unless self.instance_methods.include?('months')
  def years() 365 * days end unless self.instance_methods.include?('years')
  def decades() 10 * years end unless self.instance_methods.include?('decades')
  # This causes RDoc to hurl:
  %w[
  microseconds milliseconds seconds minutes hours days weeks months years decades
  ].each{|m| alias_method m.chop, m}
end
