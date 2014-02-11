# -*- coding: utf-8 -*-
class SuppliersController < ApplicationController
  load_and_authorize_resource
  respond_to :js, except: [:index]
  layout 'settings'

  def index
    @suppliers = Supplier.page params[:page]
  end

  def create
    Supplier.create supplier_params.merge(user_id: current_user.id.to_s)
  end

  def edit
  end

  def update
    @supplier.update(supplier_params)
  end

  def destroy
    @supplier.destroy
  end

  private
  def supplier_params
    params.require(:supplier).permit(:contact, :description, :name, :thing_title, :url)
  end
end
