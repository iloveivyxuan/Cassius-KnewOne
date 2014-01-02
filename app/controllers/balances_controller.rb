class BalancesController < ApplicationController
  before_action :require_signed_in
  layout 'settings'

  def index
  end
end
