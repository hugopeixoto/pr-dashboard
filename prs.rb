require 'net/http'
require 'json'

class Github < Struct.new(:access_token)
  def pull_requests(repo)
    paginated(
      "https://api.github.com/repos/#{repo}/pulls",
      Authorization: "token #{access_token}",
      Accept: "application/vnd.github.symmetra-preview+json",
    )
  end

  def repos(organization)
    paginated(
      "https://api.github.com/orgs/#{organization}/repos",
      Authorization: "token #{access_token}",
      Accept: "application/vnd.github.symmetra-preview+json",
    )
  end

  private
  def paginated(starting_url, headers)
    url = starting_url

    result = []
    while url do
      uri = URI(url)
      req = Net::HTTP::Get.new(uri)
      headers.each { |k, v| req[k] = v }

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

      url = res["link"]&.yield_self { |links| links.scan(/<(.*?)>; rel="(.*?)"/).map(&:reverse).to_h["next"] }

      result += JSON.parse(res.body)
    end

    result
  end
end

gh = Github.new(ARGV.fetch(0))

by_reviewer = gh.repos(ARGV.fetch(1))
  .flat_map { |repo| gh.pull_requests(repo["full_name"]) }
  .flat_map { |pr| pr["requested_reviewers"].map { |reviewer| { reviewer: reviewer, pr: pr } } }
  .group_by { |review| review[:reviewer] }
  .transform_values { |reviews| reviews.map { |r| r[:pr] } }
  .to_a

puts JSON.generate(by_reviewer)
