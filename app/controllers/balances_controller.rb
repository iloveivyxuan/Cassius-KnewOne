class BalancesController < ApplicationController
  before_action :require_signed_in
  layout 'settings'
  skip_before_action :require_not_blocked

  def index
  end
end
