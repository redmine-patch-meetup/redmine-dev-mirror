#!/usr/bin/env ruby

require 'json'

require 'faraday'

REPO = 'redmine-patch-meetup/redmine-dev-mirror'

WORKFLOW_RUN = JSON.parse ENV['WORKFLOW_RUN_JSON']

CONNECTION = Faraday.new('https://api.github.com/') do |conn|
  conn.response :raise_error
  conn.adapter Faraday.default_adapter
end

def repo_resource(resource)
  "repos/#{REPO}/#{resource}"
end

def get_repo_resource(resource)
  response = CONNECTION.get repo_resource(resource)
  JSON.parse response.body
end

def post_to_repo_resource(resource, body)
  response = CONNECTION.post repo_resource(resource),
                             body.to_json,
                             "Content-Type" => "application/json",
                             "Authorization" => "token #{ENV['GITHUB_TOKEN']}"
  JSON.parse response.body
end

def patch_artifact_id
  response = JSON.parse CONNECTION.get(WORKFLOW_RUN['artifacts_url']).body
  patch_artifact = response['artifacts'].find { |artifact| artifact['name'] == 'patch' }
  patch_artifact['id']
end

def get_suite_id
  suite_url = WORKFLOW_RUN['check_suite_url']
  id_start_index = suite_url.rindex('/') + 1
  suite_url[id_start_index..-1]
end

def patch_artifact_download_url
  "https://github.com/#{REPO}/suites/#{get_suite_id}/artifacts/#{patch_artifact_id}"
end

def pull_request_number
  WORKFLOW_RUN.dig('pull_requests', 0, 'number')
end

def post_pr_comment(pr_number, comment)
  post_to_repo_resource "issues/#{pr_number}/comments", { body: comment }
end

def find_previous_comment_id(pr_number)
  comments = get_repo_resource "issues/#{pr_number}/comments"
  previous_comment = comments.find { |comment|
    comment['body'].include?('Patch can be downloaded [here]') && comment['user']['login'].include?('github-actions')
  }
  previous_comment['id'] if previous_comment
end

def delete_comment(comment_id)
  CONNECTION.delete repo_resource("issues/comments/#{comment_id}"), nil, "Authorization" => "token #{ENV['GITHUB_TOKEN']}"
end

def main
  existing_comment_id = find_previous_comment_id(pull_request_number)
  delete_comment(existing_comment_id) if existing_comment_id

  post_pr_comment pull_request_number, "Patch can be downloaded [here](#{patch_artifact_download_url})" if pull_request_number
end

main if __FILE__ == $0
