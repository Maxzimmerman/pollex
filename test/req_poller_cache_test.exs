defmodule PllEngineTest do
  use ExUnit.Case, async: true
  doctest ReqPollerCache

  setup do
    name = :"poller_test_#{System.unique_integer()}"
    interval = 10
    pid = start_supervised!({ReqPollerCache, [request: "http://google.com", interval: :timer.seconds(interval), name: name]})
    {:ok, name: name, pid: pid, interval: interval}
  end

  test "poller state should be nil initially", %{name: name} do
    assert ReqPollerCache.get(name) == nil
  end

  test "poller state updates after interval passes", %{pid: pid, name: name} do
    send(pid, :poll)

    Process.sleep(:timer.seconds(20))
    refute ReqPollerCache.get(name) == nil
  end

  test "check state before interval, so it should be nil", %{pid: pid, name: name} do
    send(pid, :poll)

    assert ReqPollerCache.get(name) == nil
  end
end
