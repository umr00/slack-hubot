const DeleteBrain = require('../scripts/delete-brain');

class AutoDeleteMessage {
	constructor(robot, channel) {
		this.robot = robot;
		this.channel = channel;
		this.brain = new DeleteBrain(this.robot);
	}

	post_with_day(text, current_time, day) {
		return this.post(text, current_time, day*1000*60*60*24);
	}

	post_with_hour(text, current_time, hour) {
		return this.post(text, current_time, hour*1000*60*60);
	}

	post(text, current_time, delete_interval) {
		// We use slack web API because robot.messageRoom does not return timestamp of send message
		this.robot.logger.debug("bot will send a message to:" + this.channel);
		(async () => {
			const res = await this.robot.adapter.client.web.chat.postMessage(this.channel, text, {as_user: true});
			this.robot.logger.debug("time stamp of posted message:" + res.ts);
			this.brain.add(current_time, this.channel, res.ts, delete_interval);
		})();
	}
}
		//@brain.add(current_time, @channel, res.ts, delete_interval)

		//@robot.adapter.client._apiCall 'chat.postMessage',
		//	channel: @channel
		//	text: text
		//	as_user: true
		//, (res) => @brain.add(current_time, @channel, res.ts, delete_interval)

module.exports = AutoDeleteMessage;
