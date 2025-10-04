const sequelize = require('../config/db');

const User = require('./User');
const Parent = require('./Parent');
// const Child = require('./Child');
// const Diagnosis = require('./Diagnosis');
// const Specialist = require('./Specialist');
// const Institution = require('./Institution');
// const Session = require('./Session');
// const Payment = require('./Payment');
// const Evaluation = require('./Evaluation');
// const AI_Parent_Interaction = require('./AI_Parent_Interaction');
// const AI_Donor_Report = require('./AI_Donor_Report');
// const AI_Specialist_Insight = require('./AI_Specialist_Insight');
// const Message = require('./Message');
// const Post = require('./Post');
// const Donation = require('./Donation');
// const VacationRequest = require('./VacationRequest');

module.exports = {
  sequelize,
  User,
  Parent
//   Child,
//   Diagnosis,
//   Specialist,
//   Institution,
//   Session,
//   Payment,
//   Evaluation,
//   AI_Parent_Interaction,
//   AI_Donor_Report,
//   AI_Specialist_Insight,
//   Message,
//   Post,
//   Donation,
//   VacationRequest
};
