module IdsSortable
  extend ActiveSupport::Concern

  module ClassMethods
    def sort_by_ids(f, klass)
      class_eval <<-EVAL
        def #{f}_sorted_by_ids(page = 1, per = 24)
          page = page ? page.to_i : 1
          field = self.send(:"#{f.to_s.singularize}_ids").uniq
          count = field.size
          offset = per * (page - 1)
          ranged = field[(offset)..(offset + per - 1)] || []
          current_records = #{klass.to_s}.where(:id.in => ranged).sort_by {|t| field.index(t.id)}
          Kaminari.paginate_array(current_records, total_count: count, offset: (per * (page - 1))).page(page).per(per)
        end
      EVAL
    end
  end
end
