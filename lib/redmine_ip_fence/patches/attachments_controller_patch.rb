module RedmineIpFence
  module Patches
    module AttachmentsControllerPatch
      def self.prepended(base)
        Rails.logger.info "IP Fence: Starting to prepend to AttachmentsController"
        
        base.class_eval do
          after_action :record_uploader_ip, only: [:upload]
          before_action :check_download_permission, only: [:download]
        end
        
        Rails.logger.info "IP Fence: Successfully prepended to AttachmentsController"
      end

      private

      def record_uploader_ip
        @attachment ||= Attachment.order('id DESC').first
        unless @attachment
          Rails.logger.error "IP Fence ERROR: Failed to find attachment"
          return
        end
        
        Rails.logger.info "IP Fence: Recording IP for attachment #{@attachment.id}"
        @attachment.update_columns(
          ip: user_ip,
          is_sensitive: ip_matched?(user_ip)
        )
        Rails.logger.info "IP Fence: Updated attachment #{@attachment.id} with IP #{@attachment.ip}, sensitive: #{@attachment.is_sensitive}"
      end

      def check_download_permission
        # 当附件ip为空或is_sensitive为空时，允许下载
        attachment_ip_empty = @attachment.ip.nil? || @attachment.ip.to_s.empty?
        return true if attachment_ip_empty || @attachment.is_sensitive.nil?
        
        # 仅当附件标记为敏感且访问者IP不匹配时才拒绝
        if @attachment.is_sensitive
          if ip_matched?(user_ip)
            return true
          else
            render_error message: l(:error_message_internal_file), status: 403
            return false
          end
        end
        return true
      end

      def user_ip
        request.headers['X-Forwarded-For'] || request.remote_ip
      end

      def ip_matched?(ip)
        ranges = Array(Setting.plugin_redmine_ip_fence[:ip_ranges])
        Rails.logger.info "IP Fence: Checking IP #{ip} against ranges: #{ranges.inspect}"
        
        ranges.any? do |range|
          # 将IP段转换为正则表达式
          pattern = range.to_s.gsub('.', '\.').gsub('*', '[0-9]+')
          regex = Regexp.new("^#{pattern}$")
          matched = ip.match?(regex)
          Rails.logger.info "IP Fence: Checking #{ip} against #{range} (regex: #{regex.source}) => #{matched}"
          matched
        end.tap do |result|
          Rails.logger.info "IP Fence: Final match result for #{ip}: #{result}"
        end
      end
    end
  end
end
