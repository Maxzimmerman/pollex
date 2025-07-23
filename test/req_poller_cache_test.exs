defmodule PllEngineTest do
  # This ensures each test has its own fresh isolated process provided by the setup
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog

  setup do
    name = :"poller_test_#{System.unique_integer()}"
    interval = 1
    pid = start_supervised!({ReqPollerCache, [request: "http://google.com", interval: :timer.seconds(interval), name: name]})
    {:ok, name: name, pid: pid, interval: interval}
  end

  # Test the loop
  test "test check the state initialy and after some time", %{name: name, pid: pid} do
    # initialy the state should be nil
    assert ReqPollerCache.get(name) == nil

    send(pid, :poll)
    Process.sleep(:timer.seconds(1))
    refute ReqPollerCache.get(name) == nil
  end

  # Test by manually call the send function
  test "test check the state initialy and after triggering the poll", %{name: name, interval: interval} do
    # initialy the state should be nil
    assert ReqPollerCache.get(name) == nil

    Process.sleep(:timer.seconds(interval + 2))
    refute ReqPollerCache.get(name) == nil
  end

  # Test poll fails
  test "logs a warning when polling fails" do
    name = :"poller_fail_#{System.unique_integer([:positive])}"
    interval = 1
    bad_url = "http://localhost:9999"

    pid = start_supervised!(
      {ReqPollerCache, [request: bad_url, interval: :timer.seconds(interval), name: name]},
      id: name
    )

    log = capture_log(fn ->
      send(pid, :poll)
      Process.sleep(200)
    end)

    assert log =~ "got exception, will retry"
  end
end
