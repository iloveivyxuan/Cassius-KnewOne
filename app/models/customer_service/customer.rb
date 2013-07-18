module CustomerService
  class Customer
    attr_reader :client_id, :user_id
    attr_accessor :staff

    delegate :email, :name, :to => :user

    def initialize(client_id, user_id)
      @client_id = client_id.to_s
      @user_id = user_id.to_s
    end

    def channel
      @client_id.to_s
    end

    def user
      ::User.find @user_id
    end

    def ask(body, meta = {})
      dialog = Dialog.new :body => body
      dialog.user = self.user
      dialog.sender = self.user
      dialog.meta = meta
      dialog.save!
      dialog
    end

    def recent(limit = 10)
      Dialog.limit(limit).sort(:natural => 1)
    end
  end
end
