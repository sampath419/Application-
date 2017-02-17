# -*- coding: utf-8 -*-
#
# = Rdaw
# Copyright 2011 Apple Inc. All rights reserved.
#

require 'spec_helper'

describe Rdaw::ControllerExtensions::GroupHelpers do
  subject { DummyRdawController.new }

  context 'instance methods' do
    before(:each) { subject.stub!(:daw_session_data).and_return({'allGroups'=>'0;35339;43228;43246;56402;'}) }

    describe '#in_ds_groups?' do
      it 'raises an ArgumentError unless the groups key responds to map' do
        expect { subject.in_ds_groups?({ :groups => 0 }) }.to raise_error ArgumentError,
          'Please specify a list of group IDs in the :groups key value of the argument hash'
      end

      it 'allows only integer group IDs' do
        subject.in_ds_groups?({ :groups => [nil] }).should be_false
      end

      it 'does not allow non-integer strings' do
        subject.in_ds_groups?({ :groups => ['3d', '35339'] }).should be_false
      end

      it 'allows nested arrays (of Fixnums)' do
        subject.in_ds_groups?({ :groups => [[35339]] }).should be_true
      end
    end # in_ds_groups?

    describe '#in_all_groups?' do
      it 'uses in_ds_groups?' do
        subject.should_receive(:in_ds_groups?).with(:groups => 0, :fold => :all?)
        subject.in_all_groups?(0)
      end

      it 'returns true if it belongs to all groups' do
        subject.in_all_groups?([0, 35339]).should be_true
      end

      it 'returns false if it only belongs to some groups' do
        subject.in_all_groups?([0, 1337]).should be_false
      end
    end # in_any_group?

    describe '#in_any_group?' do
      it 'uses in_ds_groups?' do
        subject.should_receive(:in_ds_groups?).with(:groups => 0, :fold => :any?)
        subject.in_any_group?(0)
      end

      it 'returns true if it belongs to any group' do
        subject.in_any_group?([0, 1337]).should be_true
      end

      it 'returns false if it does not belongs to any group' do
        subject.in_any_group?([1337]).should be_false
      end
    end # in_any_group?

    describe '#in_group?' do
      it 'uses in_ds_groups?' do
        subject.should_receive(:in_ds_groups?).with(:groups => [0])
        subject.in_group?(0)
      end

      it 'returns true if the group matches' do
        subject.in_group?(0).should be_true
      end

      it 'returns false if the group does not match' do
        subject.in_group?(1337).should be_false
      end
    end # in_group?

    describe '#daw_group_ids' do
      it 'gets the raw groups from daw_session_data and parses it into an array' do
        subject.should_receive(:daw_session_data).and_return({'allGroups'=>'0;35339;43228;43246;56402;'})
        subject.daw_group_ids.should =~ [0, 35339, 43228, 43246, 56402]
      end

      it 'raises an error when allGroups key-value is not set' do
        subject.should_receive(:daw_session_data).and_return({})
        expect { subject.daw_group_ids }.to raise_error RuntimeError
      end

      it 'eliminates empty groups from the array' do
        subject.should_receive(:daw_session_data).and_return({'allGroups'=>'0;;;;;'})
        subject.daw_group_ids.should eq [0]
      end

      it 'converts all values to Fixnum' do
        subject.daw_group_ids.each { |v| v.should be_an_instance_of Fixnum }
      end
    end # daw_group_ids
  end # class methods
end # Rdaw::ControllerExtensions::GroupHelpers
