module VCloudCloud
  module Steps
    class InsertCatalogMedia < Step
      def perform(name, &block)
        media, _ = client.media name
        params = VCloudSdk::Xml::WrapperFactory.create_instance 'MediaInsertOrEjectParams'
        params.media_href = media.href
        vm = state[:vm]
        @logger.debug "INSERTMEDIA #{media.name} into VM #{vm.name}"
        client.timed_loop do
          media = client.reload media
          vm = client.reload vm
          if media.running_tasks.empty?
            client.invoke_and_wait :post, vm.insert_media_link,
                    :payload => params,
                    :headers => { :content_type => VCloudSdk::Xml::MEDIA_TYPE[:MEDIA_INSERT_EJECT_PARAMS] }
            break
          else
            media = client.wait_entity media
          end
        end
        state[:vm] = client.reload vm
      end
    end
  end
end
