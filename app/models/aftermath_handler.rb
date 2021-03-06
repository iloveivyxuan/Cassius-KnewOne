require 'singleton'
class AftermathHandler
  class<< self
    def comment_create(comment)
      comment.related_users.each do |receiver|
        context = comment.post || comment.thing_list
        receiver.notify :comment, context: context, sender: comment.author, opened: false, data: {comment_id: comment.id}
      end
    end

    def review_create(review)
      u = review.author

      ReviewNotificationWorker.perform_async(review.id.to_s, :new_review, sender_id: u.id.to_s, opened: false)
    end

    def review_vote(review, voter)
      u = review.author
      if u != voter
        u.notify :love_review, context: review, sender: voter
      end
    end

    def feeling_vote(feeling, voter)
      u = feeling.author
      if u != voter
        u.notify :love_feeling, context: feeling, sender: voter
      end
    end

    def order_confirm_payment!(order, trade_no, price, method, raw)
      u = order.user

      if order.payment_method != :btc
        u.inc expenses_count: order.trade_price.to_i,
              orders_count: 1
      else
        u.inc orders_count: 1
      end
    end

    def order_refund!(order)
      u = order.user

      if order.payment_method != :btc
        u.inc expenses_count: -order.trade_price.to_i,
              orders_count: -1
      else
        u.inc orders_count: -1
      end
    end

    def order_refund_to_balance!(order, price)
      u = order.user

      if order.payment_method != :btc
        u.inc expenses_count: -order.trade_price.to_i,
              orders_count: -1
      else
        u.inc orders_count: -1
      end
    end

    def order_confirm_free!(order)
      u = order.user

      u.inc orders_count: 1
    end

    def member_create(member)
      u = member.user
      u.inc groups_count: 1
    end

    def member_destroy(member)
      u = member.user
      u.inc groups_count: -1 if u.groups_count > 0
    end

    def topic_vote(topic, voter)
      u = topic.author
      if u != voter
        u.notify :love_topic, context: topic, sender: voter
      end
    end
  end
end
