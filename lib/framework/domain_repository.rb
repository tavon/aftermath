# The storage mechanism for our core domain.It provides a very simple contract :
#
#  #find(uuid)
#  #save(aggregate, version)
#
# This repository interface is backed by an Event and Aggregate Store which serves as a history
# of intent and allows for rebuiling Aggregates form stored events.
#

class Aftermath::DomainRepository < Aftermath::Repository
  def find(uuid)
    events = @storage.find(uuid)
    type = events.first[0]
    events.map!{|e| Aftermath::Event.reconstitute(e[2], e[1]) }
    trace{ puts " rebuild #{type}(#{uuid}) from #{events.map{|e| e.inspect }.join(', ')}" }
    eval(type).rebuild(events)
  end

  def save(aggregate, version = nil)
    version ||= aggregate.version
    trace{ puts " #{aggregate.class} @ version #{version}" }
    trace{ puts "<= #{aggregate.changes.map{|e| e.inspect }.join(', ')}" }
    if new_version = @storage.save(aggregate.class, aggregate.uuid, aggregate.changes, version)
      aggregate.commit
      trace{ puts " #{aggregate.class} @ new version #{new_version}" }
    end
    trace{ puts "---------- end consistency boundary ----------" }
  end
end