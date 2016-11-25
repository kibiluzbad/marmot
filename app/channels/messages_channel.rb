#
# Created on Fri Nov 25 2016
#
# Copyright (c) 2016 Your Company
#

# == MessagesChannel
class MessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'messages'
  end
end
