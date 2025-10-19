
const sequelize = require('../config/db');

const User = require('./User');
const Parent = require('./Parent');
const Child = require('./Child');
const Diagnosis = require('./Diagnosis');
const Specialist = require('./Specialist');
const Institution = require('./Institution');
const Session = require('./Session');
const Payment = require('./Payment');
const Evaluation = require('./Evaluation');
const EvaluationAttachment = require('./EvaluationAttachment');
const SessionType = require('./SessionType');
const SpecialistSchedule = require('./SpecialistSchedule');
const ChildRegistrationRequest = require('./ChildRegistrationRequest');
const SpecialistRegistrationRequest = require('./SpecialistRegistrationRequest');
const VacationRequest = require('./VacationRequest');

// العلاقات الإضافية
const AIDonorReport = require('./AIDonorReport');
const AIParentInteraction = require('./AIParentInteraction');
const AIRecommendation = require('./AIRecommendation');
const AISpecialistInsight = require('./AISpecialistInsight');
const Message = require('./Message');
const Post = require('./Post');
const Donation = require('./Donation');
const Resource = require('./Resource');
const ResourceDiagnosis = require('./ResourceDiagnosis');

module.exports = {
  sequelize,
  User,
  Parent,
  Child,
  Diagnosis,
  Specialist,
  Institution,
  Session,
  Payment,
  Evaluation,
  EvaluationAttachment,
  SessionType,
  SpecialistSchedule,
  ChildRegistrationRequest,
  SpecialistRegistrationRequest,
  VacationRequest,
  AIDonorReport,
  AIParentInteraction,
  AIRecommendation,
  AISpecialistInsight,
  Message,
  Post,
  Donation,
  Resource,
  ResourceDiagnosis
};