module ActiveModel::Associations
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'activemodel-associations' do |_|
      ActiveModel::Associations::Hooks.init
    end
  end
end
