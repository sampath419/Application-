# -*- coding: utf-8 -*-
#
# = Rdaw
# Copyright 2011 Apple Inc. All rights reserved.
#

module Rdaw::ControllerExtensions::GroupHelpers
  # Asserts if the provided groups are a part of <tt>daw_session_data['allGroups'] according to a <tt>fold</tt> strategy.
  #
  # == Arguments and options
  # This method receives a Hash of options, as follows:
  # * <tt>:groups><tt> An array of groups, or an array of arrays of groups.
  # * <tt>:fold</tt> The folding strategy (:any? or :all?)
  #
  # == Defaults
  # * <tt>:fold</tt> defaults to :any?
  #
  # == Examples
  #   subject.in_ds_groups?({ :groups => [0] })
  #
  #   subject.in_ds_groups?({ :groups => [0,1,2,3], :fold => :all? })
  #
  # *Note:* This is an internal method.
  def in_ds_groups?(p_options)
    unless p_options[:groups].respond_to?(:map)
      raise ArgumentError.new 'Please specify a list of group IDs in the :groups key value of the argument hash'
    end

    unless p_options[:groups].flatten.all? {|group| Fixnum === group || (String === group && group =~ /^\d+$/) }
      logger.error "Error: all group IDs must be integers #{p_options[:groups].inspect}"
      return false
    end

    groups = p_options[:groups].flatten.map(&:to_i)

    groups.send((p_options[:fold] || :any?)) do |group|
      daw_group_ids.include?(group)
    end
  end

  # Returns <tt>true</tt> if user is in each and every one of the groups specified by an array of group DSIDs.
  def in_all_groups?(p_groups)
    in_ds_groups?(:groups => p_groups, :fold => :all?)
  end

  # Returns <tt>true</tt> if user is in any one of the groups specified by an array of group DSIDs.
  def in_any_group?(p_groups)
    in_ds_groups?(:groups => p_groups, :fold => :any?)
  end

  # Returns <tt>true</tt> if user is in the group specified by a single group DSID.
  def in_group?(p_group)
    in_ds_groups?(:groups => [p_group])
  end

  # Parses <tt>daw_session_data['allGroups']</tt> String into an Array of groups, where all its elements are of type Fixnum.
  #
  # == Behaviors
  # * Empty elements in <tt>daw_session_data['allGroups']</tt> are rejected.
  #
  # == Defaults
  # * An empty String is used if <tt>daw_session_data['allGroups']</tt> is not present.
  def daw_group_ids
    groups = daw_session_data['allGroups']
    raise RuntimeError.new 'To use group methods, allGroups should be in Rdaw::DAW_FUNC' unless groups
    groups.split(';').reject(&:empty?).map(&:to_i)
  end
end # Rdaw::ControllerExtensions::GroupHelpers
