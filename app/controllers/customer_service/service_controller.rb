module CustomerService
  class ServiceController < ::WebsocketRails::BaseController
    def initialize_session
      controller_store[:customers] = {}
      controller_store[:staffs] = {}
    end

    def client_connected
      if current_user.role?(:admin)
        staff = online_staff

        broadcast_to 'admin', :staff_online, notice_message(staff)
      else
        customer = online_customer

        broadcast_to 'admin', :customer_online, notice_message(customer)
      end
    end

    def client_disconnected
      if current_user.role?(:admin)
        staff = offline_staff
        staff.customers.values.each do |c|
          if another_staff = online_staffs.values.sample
            another_staff.serve c

            broadcast_to 'admin', :customer_assign_changed, notice_message(c,
                                                                           :from => staff.name,
                                                                           :to => c.staff.name)
            broadcast_to another_staff.channel, :customer_assign, notice_message(customer,
                                                                                 :channel => c.channel,
                                                                                 :location => message[:location])
            broadcast_to c.channel, :staff_changed, {:time => Time.now}
          else
            broadcast_to c.channel, :no_staff, {:time => Time.now}
          end
        end

        broadcast_to 'admin', :staff_offline, notice_message(staff)
      else
        if staff = current_customer.staff
          broadcast_to staff.channel, :customer_offline, notice_message(current_customer,
                                                                        :channel => current_customer.channel)
        end
        customer = offline_customer

        broadcast_to 'admin', :customer_offline, notice_message(customer)
      end
    end

    def customer_assign
      customer = current_customer
      if staff = online_staffs.values.sample
        staff.serve(customer)

        broadcast_to staff.channel, :customer_assign, notice_message(customer,
                                                                     :customer_id => customer.user_id,
                                                                     :channel => customer.channel,
                                                                     :location => message[:location])
        trigger_success({})
      else
        trigger_failure({})
      end
    end

    def ask
      if dialog = current_customer.ask(message[:body])
        if current_customer.staff
          broadcast_to current_customer.staff.channel, :customer_ask,
                       content_message(current_customer, dialog, :channel => current_customer.channel)
          broadcast_to current_customer.channel, :customer_ask, content_message(current_customer, dialog)
        end
        trigger_success({})
      else
        trigger_failure({})
      end
    end

    def answer
      if dialog = current_staff.answer(message[:customer_id], message[:body])
        customer_channel = current_staff.customer(message[:customer_id]).channel
        broadcast_to customer_channel, :staff_answer, content_message(current_staff, dialog)

        broadcast_to current_staff.channel, :staff_answer,
                     content_message(current_staff, dialog, :channel => customer_channel)
        trigger_success({})
      else
        trigger_failure({})
      end
    end

    def customer_context
      if current_user.role?(:admin)
        dialogs = current_staff.customer(message[:customer_id]).recent
      else
        dialogs = current_customer.recent
      end
      context = dialogs.collect do |d|
        {
            :body => d.body,
            :time => d.created_at,
            :identity => d.sender.name,
            :avatar => d.sender.avatar.url(:small),
            :kind => d.kind
        }
      end

      trigger_success(context)
    end

    def has_online_staff
      trigger_success({:result => (online_staffs.length > 0)})
    end

    private
    def notice_message(sender, extra = {})
      {:identity => sender.name, :time => Time.now}.merge extra
    end

    def content_message(sender, content, extra = {})
      {
          :body => content.body,
          :time => content.created_at,
          :identity => sender.name,
          :avatar => sender.avatar
      }.merge extra
    end

    def online_customers
      controller_store[:customers]
    end

    def online_staffs
      controller_store[:staffs]
    end

    def online_customer
      customer = Customer.new client_id, current_user.id
      online_customers.merge! client_id => customer
      customer
    end

    def current_customer
      online_customers[client_id]
    end

    def current_staff
      online_staffs[client_id]
    end

    def online_staff
      staff = Staff.new client_id, current_user.id
      online_staffs.merge! client_id => staff
      staff
    end

    def offline_customer
      if staff = current_customer.staff
        staff.deserve current_customer
      end
      customer = online_customers.delete client_id
      customer
    end

    def offline_staff
      online_staffs.delete client_id
    end

    def broadcast_to(channel, event, message)
      WebsocketRails[channel].trigger event, message
    end
  end
end
