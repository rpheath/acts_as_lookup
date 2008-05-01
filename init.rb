require 'acts_as_lookup'

ActiveRecord::Base.send(:include, RPH::ActsAsLookup)
ActionView::Base.send(:include, RPH::ActsAsLookup::ViewHelpers)