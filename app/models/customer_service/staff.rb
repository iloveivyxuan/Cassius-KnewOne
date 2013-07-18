module CustomerService
  class Staff
    attr_reader :client_id, :user_id
    attr_reader :customers

    delegate :email, :to => :user

    def initialize(client_id, user_id)
      @client_id = client_id.to_s
      @user_id = user_id.to_s
      @customers = {}
    end

    def user
      ::User.find @user_id
    end

    def serve(customer)
      customer.staff = self
      @customers.merge! customer.user_id => customer
    end

    def deserve(customer)
      customer.staff = nil
      @customers.delete customer.user_id
    end

    def answer(customer_id, body)
      dialog = Dialog.new :body => body
      dialog.user = @customers[customer_id].user
      dialog.sender = self.user
      dialog.save!
      dialog
    end

    def customer(customer_id)
      @customers[customer_id]
    end

    def channel
      @client_id
    end
  end

end
