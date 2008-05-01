require 'acts_as_lookup'

ActiveRecord::Base.send(:include, RyanHeath::ActsAsLookup)
ActionView::Base.send(:include, RyanHeath::ActsAsLookup::ViewHelpers)