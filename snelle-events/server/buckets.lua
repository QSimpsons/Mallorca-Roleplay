Buckets = {}

local bucketCounter = 0

function Buckets.Assign(event)
    if not Config.UseRoutingBuckets then
        event.bucket = 0
        return 0
    end

    bucketCounter = bucketCounter + 1
    event.bucket = Config.RoutingBucketBase + bucketCounter
    return event.bucket
end

function Buckets.SetPlayer(source, bucket)
    if not Config.UseRoutingBuckets then return end
    SetPlayerRoutingBucket(source, bucket or 0)
end

function Buckets.ResetPlayer(source)
    Buckets.SetPlayer(source, 0)
end
