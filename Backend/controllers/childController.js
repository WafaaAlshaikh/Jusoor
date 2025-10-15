const Child = require('../model/Child');

// ================= GET CHILDREN =================
exports.getChildren = async (req, res) => {
  try {
    const parentId = req.user.user_id; 
    const children = await Child.findAll({ where: { parent_id: parentId } });
    res.status(200).json(children);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ================= ADD CHILD =================
exports.addChild = async (req, res) => {
  try {
    const parentId = req.user.user_id;
    const { full_name, date_of_birth, gender, diagnosis_id, photo, medical_history } = req.body;

    const newChild = await Child.create({
      parent_id: parentId,
      full_name,
      date_of_birth,
      gender,
      diagnosis_id,
      photo,
      medical_history
    });

    res.status(201).json(newChild);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to add child' });
  }
};

// ================= UPDATE CHILD =================
exports.updateChild = async (req, res) => {
  try {
    const childId = req.params.id;
    const { full_name, date_of_birth, gender, diagnosis_id, photo, medical_history } = req.body;

    const child = await Child.findByPk(childId);
    if (!child) return res.status(404).json({ message: 'Child not found' });

    await child.update({ full_name, date_of_birth, gender, diagnosis_id, photo, medical_history });
    res.status(200).json(child);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to update child' });
  }
};

// ================= DELETE CHILD =================
exports.deleteChild = async (req, res) => {
  try {
    const childId = req.params.id;
    const child = await Child.findByPk(childId);
    if (!child) return res.status(404).json({ message: 'Child not found' });

    await child.destroy();
    res.status(200).json({ message: 'Child deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to delete child' });
  }
};
