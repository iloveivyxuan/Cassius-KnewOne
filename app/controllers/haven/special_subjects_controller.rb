module Haven
  class SpecialSubjectsController < Haven::ApplicationController
    layout 'settings'
    before_action :set_special
    before_action :set_special_subject, except: [:create, :new]

    def edit

    end

    def new
      @subject = @special.special_subjects.build
    end

    def update
      @subject.update_attributes subject_params

      redirect_to edit_haven_special_url(@special)
    end

    def create
      @subject = @special.special_subjects.build subject_params

      if @subject.save
        redirect_to edit_haven_special_url(@special)
      else
        render 'new'
      end
    end

    def destroy
      @subject.destroy

      redirect_to edit_haven_special_url(@special)
    end

    private

    def subject_params
      params.require(:special_subject).permit!
    end

    def set_special
      @special = Special.find(params[:special_id])
    end

    def set_special_subject
      @subject = @special.special_subjects.find(params[:id])
    end
  end
end
