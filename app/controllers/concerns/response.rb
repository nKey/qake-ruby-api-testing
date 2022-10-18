module Response
  def json_response(object, status = :ok)
    render json: object, status: status
  end
  def jsonFormated_response(object, status = :ok)
    render json: object, status: status
  end
end
