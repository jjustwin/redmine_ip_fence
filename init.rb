require 'redmine'

require_relative 'lib/redmine_ip_fence/patches/attachments_controller_patch'

Redmine::Plugin.register :redmine_ip_fence do
  name 'Redmine IP Fence Plugin'
  author 'Your Name'
  description 'Attachment network isolation plugin for Redmine'
  version '0.1.0'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  requires_redmine version_or_higher: '5.0.0'
  settings default: { 'ip_ranges' => [] }, partial: 'settings/ip_fence_settings'

  # 强制立即加载补丁而不依赖to_prepare
  Rails.logger.info "IP FENCE CRITICAL: Directly applying patch..."
  AttachmentsController.prepend RedmineIpFence::Patches::AttachmentsControllerPatch
  Rails.logger.info "IP FENCE CRITICAL: Direct patch applied. Ancestors: #{AttachmentsController.ancestors.map(&:name)}"
  
  # 保留to_prepare作为二次保障
  Rails.application.config.to_prepare do
    unless AttachmentsController.ancestors.include?(RedmineIpFence::Patches::AttachmentsControllerPatch)
      Rails.logger.info "IP FENCE CRITICAL: Re-applying patch in to_prepare"
      AttachmentsController.prepend RedmineIpFence::Patches::AttachmentsControllerPatch
    end
  end
end
