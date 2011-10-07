
#
# Specifying rufus-scheduler
#
# Sat Mar 21 17:43:23 JST 2009
#

require File.join(File.dirname(__FILE__), 'spec_base')


describe SCHEDULER_CLASS do

  it 'stops' do

    var = nil

    s = start_scheduler
    s.in('3s') { var = true }

    stop_scheduler(s)

    var.should == nil
    sleep 4
    var.should == nil
  end

  unless SCHEDULER_CLASS == Rufus::Scheduler::EmScheduler

    it 'sets a default scheduler thread name' do

      s = start_scheduler

      s.instance_variable_get(:@thread)['name'].should match(
        /Rufus::Scheduler::.*Scheduler - \d+\.\d+\.\d+/)

      stop_scheduler(s)
    end

    it 'sets the scheduler thread name' do

      s = start_scheduler(:thread_name => 'nada')
      s.instance_variable_get(:@thread)['name'].should == 'nada'

      stop_scheduler(s)
    end
  end

  it 'accepts a custom frequency' do

    var = nil

    s = start_scheduler(:frequency => 3.0)

    s.in('1s') { var = true }

    sleep 1
    var.should == nil

    sleep 1
    var.should == nil

    sleep 2
    var.should == true

    stop_scheduler(s)
  end
end

describe 'Rufus::Scheduler#start_new' do

  it 'piggybacks EM if present and running' do

    s = Rufus::Scheduler.start_new

    s.class.should == SCHEDULER_CLASS

    stop_scheduler(s)
  end
end

