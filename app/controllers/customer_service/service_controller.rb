module CustomerService
  class ServiceController < ::WebsocketRails::BaseController
    def initialize_session
      controller_store[:customers] = {}
      controller_store[:staffs] = {}
    end

    def client_connected
      if current_user.role?(:admin)
        staff = Staff.new client_id, current_user.id
        online_staff staff

        broadcast_to 'admin', :staff_online, {:identity => staff.name, :time => Time.now}
      else
        customer = Customer.new client_id, current_user.id
        online_customer customer

        broadcast_to 'admin', :customer_online, {:identity => customer.name, :time => Time.now}
      end
    end

    def client_disconnected
      if current_user.role?(:admin)
        staff = offline_staff
        staff.customers.each do |c|
          online_staffs.values.sample.serve c
          staff.serve(c)

          broadcast_to 'admin', :customer_assign_changed, {:from => staff.name,
                                                           :to => c.staff.name,
                                                           :identity => c.name,
                                                           :time => Time.now}
          broadcast_to staff.channel, :customer_assign, {
              :channel => c.channel,
              :identity => customer.name,
              :location => message[:location],
              :time => Time.now}
        end

        broadcast_to 'admin', :staff_offline, {:identity => staff.name, :time => Time.now}
      else
        if staff = current_customer.staff
          broadcast_to staff.channel, :customer_offline, {:identity => current_customer.name,
                                                          :channel => current_customer.channel,
                                                          :time => Time.now}
        end
        customer = offline_customer

        broadcast_to 'admin', :customer_offline, {:identity => customer.name, :time => Time.now}
      end
    end

    def customer_assign
      customer = current_customer
      if staff = online_staffs.values.sample
        staff.serve(customer)

        broadcast_to staff.channel, :customer_assign, {
            :customer_id => customer.user_id,
            :channel => customer.channel,
            :identity => customer.name,
            :location => message[:location],
            :time => Time.now}
        trigger_success({})
      else
        trigger_failure({})
      end
    end

    def ask
      if dialog = current_customer.ask(message[:body])
        if current_customer.staff
          broadcast_to current_customer.staff.channel, :customer_ask, {
              :body => dialog.body,
              :time => dialog.created_at,
              :identity => current_customer.name,
              :channel => current_customer.channel
          }
          broadcast_to current_customer.channel, :customer_ask, {
              :body => dialog.body,
              :time => dialog.created_at,
              :identity => current_customer.name
          }
        end
        trigger_success({})
      else
        trigger_failure({})
      end
    end

    def answer
      if dialog = current_staff.answer(message[:customer_id], message[:body])
        customer_channel = current_staff.customer(message[:customer_id]).channel
        broadcast_to customer_channel, :staff_answer, {
            :body => dialog.body,
            :time => dialog.created_at,
            :identity => current_staff.name
        }
        broadcast_to current_staff.channel, :staff_answer, {
            :body => dialog.body,
            :time => dialog.created_at,
            :identity => current_staff.name,
            :channel => customer_channel
        }
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
              :identity => d.sender.name,
              :body => d.body,
              :time => d.created_at
          }
        end

      trigger_success(context)
    end

    private
    def online_customers
      controller_store[:customers]
    end

    def online_staffs
      controller_store[:staffs]
    end

    def online_customer(customer)
      online_customers.merge! client_id => customer
    end

    def current_customer
      online_customers[client_id]
    end

    def current_staff
      online_staffs[client_id]
    end

    def online_staff(staff)
      online_staffs.merge! client_id => staff
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
