require 'singleton'
class AftermathHandler
  class<< self
    def comment_create(comment)
      comment.related_users.each do |receiver|
        receiver.notify :comment, context: comment.post, sender: comment.author
      end
    end

    def thing_create(thing)
      u = thing.author

      u.inc things_count: 1
    end

    def thing_destroy(thing)
      u = thing.author

      u.inc things_count: -1
    end

    def thing_fancy(thing, user)
      user.inc fancies_count: 1

      user.category_references<< thing.categories_text
    end

    def thing_unfancy(thing, user)
      user.inc fancies_count: -1

      user.category_references>> thing.categories_text
    end

    def thing_own(thing, user)
      user.inc owns_count: 1

      user.category_references<< thing.categories_text
    end

    def thing_unown(thing, user)
      user.inc owns_count: -1

      user.category_references>> thing.categories_text
    end

    def review_create(review)
      u = review.author

      u.inc reviews_count: 1
    end

    def review_destroy(review)
      u = review.author

      u.inc reviews_count: -1
    end

    def user_follow(record, user)
      record.inc followings_count: 1
      user.inc followers_count: 1
    end

    def user_unfollow(record, user)
      record.inc followings_count: -1
      user.inc followers_count: -1
    end

    def order_confirm_payment!(order)
      u = order.user

      if order.payment_method != :btc
        u.inc expenses_count: order.trade_price,
              orders_count: 1
      else
        u.inc orders_count: 1
      end
    end
  end
end
