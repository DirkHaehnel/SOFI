function [ workerList workerName ] = getWorkerInfo( )

workerName = get(getCurrentWorker,'Name');
workerList = labindex;

end

