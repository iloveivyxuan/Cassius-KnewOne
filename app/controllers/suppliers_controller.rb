# -*- coding: utf-8 -*-
class SuppliersController < ApplicationController
  load_and_authorize_resource

  def index
    @suppliers = Supplier.page params[:page]
  end

  def create
    Supplier.create params[:supplier]
    respond_to { |format| format.js }
  end

  def edit
  end

  def update
    @supplier.update_attributes(params[:supplier])
  end

  def destroy
    @supplier.destroy
  end
end
