saveVideo({
    for(i in frames) {
        plot(delta[[i]], type="l",ylim=range(delta), ylab="", main=i)
        }
    },interval=1/30)
