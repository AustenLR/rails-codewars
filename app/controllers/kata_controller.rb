class KataController < ApplicationController
  before_action :current_user
  def index
    #choose JS or ruby
    #fade out
    #ajax call 
    #
  end
 
  def create
    level = @current_user.level.to_s
    strategy = "kyu_#{level}_workout"
    language = params["language"]
    request = Typhoeus::Request.new(
      "https://www.codewars.com/api/v1/code-challenges/#{language}/train",
      method: :post,
      params: { stratgey: strategy },
      headers: { Authorization: "q-sizxUQz1x1tsnxuFnY", ContentType: "text/html;" }
    )
    response = request.run
    @result = JSON.parse(response.response_body)
    @setup = @result["session"]["setup"]
    projectId = @result["session"]["projectId"]
    solutionId = @result["session"]["solutionId"]

    @katum = Katum.create({ solutionId: solutionId,
              projectId: projectId });
    @current_user.kata << @katum
    render json: {description: @result["description"].gsub(/[```]/, ""), setup: @result["session"]["setup"]}
  end

  def submit
    solutionId = @current_user.kata.last.solutionId
    projectId = @current_user.kata.last.projectId
    answer = params["answer"]

    request = Typhoeus::Request.new(
      "https://www.codewars.com/api/v1/code-challenges/projects/#{projectId}/solutions/#{solutionId}/attempt",
      method: :post,
      params: { code: answer, output_format: "raw"},
      headers: { Authorization: "q-sizxUQz1x1tsnxuFnY", ContentType: "text/html;" }
    )
    response = request.run
    @result = JSON.parse(response.response_body)
    @dmid = @result["dmid"]
    render json: {dmid: @dmid}
  end

  def check
    dmidCheck = params["dmid"]
    binding.pry
    request_deferred = Typhoeus::Request.new(
      "https://www.codewars.com/api/v1/deferred/#{dmidCheck}",
      method: :get,
      headers: { Authorization: "q-sizxUQz1x1tsnxuFnY", ContentType: "text/html;" }
    )
    response_deferred = request_deferred.run
    @result_deferred = JSON.parse(response_deferred.response_body)
    binding.pry
    render json: @result_deferred
  end    


  private

  def kata_params
    params.require(:katum).permit(:language, :answer, :dmid)
  end

end
