# -*- coding: utf-8 -*-
class SuppliersController < ApplicationController
  load_and_authorize_resource

  def index
    @suppliers = Supplier.page supplier_params
  end

  def create
    Supplier.create supplier_params
    respond_to { |format| format.js }
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
