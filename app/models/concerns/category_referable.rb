module CategoryReferable
  extend ActiveSupport::Concern

  included do
    embeds_many :category_references do
      def <<(cates)
        cates = [cates] unless cates.is_a? Array
        cates.map! { |cate| cate.is_a?(Category) ? cate.name : cate }

        cates.each do |cate|
          if exists = where(name: cate).first
            exists.inc count: 1
          else
            create name: cate
          end
        end
      end

      def >>(cates)
        cates = [cates] unless cates.is_a? Array
        cates.map! { |cate| cate.is_a?(Category) ? cate.name : cate }

        exists = where(:name.in => cates)
        return unless exists.any?

        exists.each do |cate|
          if cate.count > 1
            cate.inc count: -1
          else
            cate.destroy
          end
        end
      end
    end

    def categories_text
      category_references.map &:name
    end

    def categories
      Category.in(name: categories_text)
    end
  end
end
