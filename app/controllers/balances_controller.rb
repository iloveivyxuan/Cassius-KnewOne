class BalancesController < ApplicationController
  before_action :authenticate_user!
  layout 'settings'

  def index
  end
end
